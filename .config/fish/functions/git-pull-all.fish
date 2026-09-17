function git-pull-all --description 'ff-pull every git repo under the given dir (default: .)'
    set -l dir $argv[1]
    test -z "$dir"; and set dir .
    for gitdir in (find $dir -name .git -type d 2>/dev/null)
        set -l repo (dirname $gitdir)
        echo "Updating $repo..."
        git -C $repo pull --ff-only 2>/dev/null; or echo "  failed or conflicts"
    end
end
