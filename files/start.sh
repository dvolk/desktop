xrdb -merge .Xresources

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
blueman-applet &

xset dpms 0 0 3600
xset s 3600

xsetroot -mod 3 3 -fg black -bg lightgreen

xmodmap -e "clear Lock"
xmodmap -e "keycode 66 = Return"

xinput set-prop "pointer:ELECOM TrackBall Mouse DEFT Pro TrackBall Mouse" 'libinput Button Scrolling Button' 11
xinput set-prop "pointer:ELECOM TrackBall Mouse DEFT Pro TrackBall Mouse" 'libinput Scroll Method Enabled' 0 0 1
