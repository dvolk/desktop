xrdb -merge .Xresources

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
blueman-applet &

xset dpms 0 0 3600
xset s 3600

xsetroot -mod 3 3 -fg black -bg lightgreen

xinput set-prop "pointer:ELECOM TrackBall Mouse DEFT Pro TrackBall Mouse" 'libinput Button Scrolling Button' 11
xinput set-prop "pointer:ELECOM TrackBall Mouse DEFT Pro TrackBall Mouse" 'libinput Scroll Method Enabled' 0 0 1

# speed up scrolling
imwheel -b "4 5"

FILE=start-local.sh
if [[ -f "$FILE" ]]; then
    bash ./start-local.sh
fi

FILE=key.sh
if [[ -f "$FILE" ]]; then
    bash ./key.sh
fi
