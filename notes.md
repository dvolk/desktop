** Autologin to vt and start X

run

    systemctl edit getty@tty1

add

    [Service]
    ExecStart=
    ExecStart=-/sbin/agetty --autologin {{ lookup('env', 'USER') }} --noclear %I 38400 linux

run

    systemctl enable getty@tty1.service

run

    systemctl disable lightdm

add to .bashrc:

    if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
        exec startx -- -nolisten tcp -dpi {{ lookup('env', 'DPI') }}
    fi
