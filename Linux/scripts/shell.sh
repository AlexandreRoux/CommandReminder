#!/bin/bash
# Bash Menu Script Example

PS3='Access to the command : '
options=("iptables rules" "passwd file" "grep examples" "Quit")
select opt in "${options[@]}"
do
    case "$REPLY" in
        1) nano /your_location/script.sh
            break
            ;;
        2) cat /etc/passwd
            break
            ;;
        3) echo "grep Examples"
                echo "grep -r --include="*" -n -i -a -A5 'your_research'
            break
            ;;
        4)
            break
            ;;
        *) echo invalid option;;
    esac
done

