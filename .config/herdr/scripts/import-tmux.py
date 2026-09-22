#!/usr/bin/env python3
"""Recreate the live tmux session tree as herdr workspaces.

    tmux session -> herdr workspace
    tmux window  -> herdr tab
    tmux pane    -> herdr pane

Split direction follows each tmux pane's geometry, so layouts come across
roughly as they were. Running processes are not moved; panes start as shells.

Panes running Claude get `claude --resume <id>` pre-typed but NOT run, the same
behaviour as tmux/scripts/resurrect-post-restore.sh. Session ids come from the
registry that tmux/scripts/claude-pane-registry.sh recorded. Where the cwd would
route the claude() wrapper to the wrong profile, the line is prefixed with an
explicit CLAUDE_CONFIG_DIR.

Usage:
    import-tmux.py --dry-run          show the plan
    import-tmux.py                    import every tmux session
    import-tmux.py --only crewview    import one session
    import-tmux.py --skip Documents   leave a session out
"""

import argparse
import json
import os
import subprocess
import sys
from collections import defaultdict
from typing import Any

REGISTRY = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")),
    "tmux-claude", "registry.jsonl",
)
HOME = os.path.expanduser("~")
WORK_PREFIX = os.path.join(HOME, "dev", "work") + os.sep

TMUX_FMT = "|".join([
    "#{session_name}", "#{window_index}", "#{window_name}", "#{pane_index}",
    "#{pane_current_path}", "#{pane_current_command}",
    "#{pane_left}", "#{pane_top}",
])


def run(cmd, dry=False):
    """Run a herdr command. Returns the parsed JSON result, or {} in dry-run."""
    if dry:
        print("    " + " ".join(cmd))
        return {}
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)}\n{proc.stderr.strip()}")
    out = proc.stdout.strip()
    if not out:
        return {}
    try:
        return json.loads(out).get("result", {})
    except json.JSONDecodeError:
        return {}


def new_window() -> dict[str, Any]:
    return {"name": "", "panes": []}


def read_tmux():
    """Return {session: {window_index: {"name": str, "panes": [pane, ...]}}}."""
    proc = subprocess.run(
        ["tmux", "list-panes", "-a", "-F", TMUX_FMT],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        sys.exit("no tmux server running, or it has no panes")
    tree = defaultdict(lambda: defaultdict(new_window))
    for line in proc.stdout.splitlines():
        parts = line.split("|")
        if len(parts) != 8:
            continue
        sess, widx, wname, pidx, cwd, cmd, left, top = parts
        win = tree[sess][int(widx)]
        win["name"] = wname
        win["panes"].append({
            "index": int(pidx), "cwd": cwd, "cmd": cmd,
            "left": int(left), "top": int(top),
            "ref": f"{sess}:{widx}.{pidx}",
        })
    for windows in tree.values():
        for win in windows.values():
            win["panes"].sort(key=lambda p: p["index"])
    return tree


def read_claude_registry():
    """Return {tmux pane ref: {"session_id", "config_dir"}}; last entry wins."""
    out = {}
    try:
        with open(REGISTRY) as fh:
            for line in fh:
                try:
                    rec = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if rec.get("pane") and rec.get("session_id"):
                    out[rec["pane"]] = rec
    except FileNotFoundError:
        pass
    return out


def resume_command(pane, registry):
    """Pre-type text for an agent pane, or None."""
    if pane["cmd"] != "claude":
        return None                      # codex/others record no session id
    rec = registry.get(pane["ref"])
    if not rec:
        return None
    # The claude() wrapper derives the profile from cwd. Prefix only when that
    # would disagree with the profile the session was actually created under.
    wrapper = "work" if (pane["cwd"] + os.sep).startswith(WORK_PREFIX) else "personal"
    recorded = os.path.basename(rec.get("config_dir", "")) or wrapper
    prefix = "" if recorded == wrapper else f"CLAUDE_CONFIG_DIR={rec['config_dir']} "
    return f"{prefix}claude --resume {rec['session_id']}"


def direction(prev, cur):
    """Infer the tmux split that produced `cur` from its position."""
    if cur["left"] > prev["left"]:
        return "right"
    if cur["top"] > prev["top"]:
        return "down"
    return "right"


def import_session(name, windows, registry, dry):
    order = sorted(windows)
    first = windows[order[0]]["panes"][0]
    print(f"  workspace {name}  ({len(order)} tabs)")
    res = run(["herdr", "workspace", "create", "--label", name,
               "--cwd", first["cwd"], "--no-focus"], dry)
    ws_id = res.get("workspace", {}).get("workspace_id")
    root_tab = res.get("tab", {}).get("tab_id")
    root_pane = res.get("root_pane", {}).get("pane_id")

    for n, widx in enumerate(order):
        win = windows[widx]
        panes = win["panes"]
        if n == 0:
            tab_pane = root_pane
            if win["name"] and win["name"] != name and root_tab:
                run(["herdr", "tab", "rename", root_tab, win["name"]], dry)
        else:
            args = ["herdr", "tab", "create", "--cwd", panes[0]["cwd"], "--no-focus"]
            if ws_id:
                args += ["--workspace", ws_id]
            if win["name"]:
                args += ["--label", win["name"]]
            tres = run(args, dry)
            tab_pane = tres.get("root_pane", {}).get("pane_id")
        print(f"    tab {win['name'] or widx}  ({len(panes)} panes)")

        prev_pane_id, prev = tab_pane, panes[0]
        pane_ids = [tab_pane]
        for cur in panes[1:]:
            args = ["herdr", "pane", "split", "--direction", direction(prev, cur),
                    "--cwd", cur["cwd"], "--no-focus"]
            if prev_pane_id:
                args += ["--pane", prev_pane_id]
            sres = run(args, dry)
            new_id = sres.get("pane", {}).get("pane_id") or sres.get("pane_id")
            pane_ids.append(new_id)
            prev_pane_id, prev = new_id, cur

        for pane, pid in zip(panes, pane_ids):
            text = resume_command(pane, registry)
            if not text:
                continue
            print(f"      resume: {pane['ref']} -> {text.split()[-1][:8]}")
            if pid:
                run(["herdr", "pane", "send-text", pid, text], dry)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--only", action="append", default=[])
    ap.add_argument("--skip", action="append", default=[])
    args = ap.parse_args()

    tree = read_tmux()
    registry = read_claude_registry()
    names = [n for n in sorted(tree)
             if (not args.only or n in args.only) and n not in args.skip]
    if not names:
        sys.exit("nothing to import")

    panes = sum(len(w["panes"]) for n in names for w in tree[n].values())
    print(f"{'DRY RUN: ' if args.dry_run else ''}{len(names)} sessions, {panes} panes\n")
    for name in names:
        import_session(name, tree[name], registry, args.dry_run)
    print("\nDone. tmux is untouched; close the workspaces you do not want.")


if __name__ == "__main__":
    main()
