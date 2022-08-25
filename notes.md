## Autologin to vt and start X

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

## Enable lxd traffic with ufw on debian 11

    ufw allow in on lxdbr0
    ufw route allow in on lxdbr0
    ufw route allow out on lxdbr0

reference: https://discuss.linuxcontainers.org/t/lxd-bridge-doesnt-work-with-ipv4-and-ufw-with-nftables/10034/27
