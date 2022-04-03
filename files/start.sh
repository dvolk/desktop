/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

xset dpms 0 0 3600
xset s 3600

xsetroot -mod 3 3 -fg black -bg lightgreen

xmodmap -e "clear Lock"
xmodmap -e "keycode 66 = Return"
