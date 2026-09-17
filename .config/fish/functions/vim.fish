function vim
    switch (count $argv)
        case 0
            nvim
        case 1
            if test -d $argv[1]
                cd $argv[1]; and nvim .
            else if test -f $argv[1]
                nvim $argv[1]
            else
                echo "$argv[1] is neither a file nor a directory"
            end
        case '*'
            echo "Usage: vim <path>?"
    end
end
