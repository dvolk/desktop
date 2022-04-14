** Autologin to vt and start X

    systemctl edit getty@tty1

add

    [Service]
    ExecStart=
    ExecStart=-/sbin/agetty --autologin {{ lookup('env', 'USER') }} --noclear %I 38400 linux


    systemctl enable getty@tty1.service


    systemctl disable lightdm


add to .bashrc:

    if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
        exec startx -- -nolisten tcp -dpi {{ lookup('env', 'DPI') }}
    fi
