#!/usr/bin/env python3
"""Share ~/.claude/settings.json across machines without leaking client context.

Claude Code has no user-level local-override file, so settings.json is
all-or-nothing. This splits it:

    settings.shared.json   tracked here; permissions, hooks, plugins, theme
    autoMode               stays on the machine; holds client names, repo
                           names and descriptions of where production
                           credentials live, none of which belong in a
                           public repo

Home paths are stored as ~ so the file works under a different username.

    sync-settings.py export   live settings -> settings.shared.json
    sync-settings.py merge    settings.shared.json -> live settings
    sync-settings.py diff     show what export would change

`merge` is run by yadm bootstrap. Run `export` after changing settings you
want on your other machines, then commit.
"""

import argparse
import json
import os
import shutil
import sys

HOME = os.path.expanduser("~")
LIVE = os.path.join(HOME, ".claude", "settings.json")
SHARED = os.path.join(HOME, ".config", "claude", "settings.shared.json")

# Never leaves this machine. autoMode is the auto-approve classifier config;
# its rules and environment notes name clients, repos and credential locations.
LOCAL_ONLY = {"autoMode"}


def load(path):
    try:
        with open(path) as fh:
            return json.load(fh)
    except FileNotFoundError:
        return {}


# Placeholder for this machine's home directory. Deliberately not "~": some
# permission rules legitimately contain "~/" (Read(~/.config/**)), and Claude
# Code understands those, so expanding them on merge would corrupt them.
HOME_TOKEN = "${HOME}"


def portable(obj):
    """Absolute home paths -> ${HOME}, so the file survives another username."""
    return json.loads(json.dumps(obj).replace(HOME, HOME_TOKEN))


def local(obj):
    """${HOME} -> this machine's home."""
    return json.loads(json.dumps(obj).replace(HOME_TOKEN, HOME))


def build_shared(live):
    return portable({k: v for k, v in live.items() if k not in LOCAL_ONLY})


def cmd_export():
    live = load(LIVE)
    if not live:
        sys.exit(f"no settings at {LIVE}")
    shared = build_shared(live)
    os.makedirs(os.path.dirname(SHARED), exist_ok=True)
    with open(SHARED, "w") as fh:
        json.dump(shared, fh, indent=2, sort_keys=True)
        fh.write("\n")
    held = sorted(LOCAL_ONLY & live.keys())
    print(f"wrote {SHARED} ({len(shared)} keys)")
    print(f"kept local: {', '.join(held) if held else 'nothing'}")


def cmd_merge():
    shared = load(SHARED)
    if not shared:
        sys.exit(f"nothing to merge: {SHARED} not found")
    live = load(LIVE)
    if live:
        shutil.copy(LIVE, LIVE + ".bak")
    merged = dict(live)
    merged.update(local(shared))          # shared wins for the keys it defines
    for k in LOCAL_ONLY:                  # never overwrite machine-local keys
        if k in live:
            merged[k] = live[k]
    os.makedirs(os.path.dirname(LIVE), exist_ok=True)
    with open(LIVE, "w") as fh:
        json.dump(merged, fh, indent=2)
        fh.write("\n")
    print(f"merged {len(shared)} shared keys into {LIVE}")


def cmd_diff():
    current = load(SHARED)
    fresh = build_shared(load(LIVE))
    if current == fresh:
        print("settings.shared.json is up to date")
        return
    for k in sorted(set(current) | set(fresh)):
        if current.get(k) != fresh.get(k):
            state = ("added" if k not in current else
                     "removed" if k not in fresh else "changed")
            print(f"  {state}: {k}")
    print("\nrun: sync-settings.py export")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("action", choices=["export", "merge", "diff"])
    a = ap.parse_args()
    {"export": cmd_export, "merge": cmd_merge, "diff": cmd_diff}[a.action]()
