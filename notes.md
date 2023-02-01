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

## problems with systemd --user

    export XDG_RUNTIME_DIR=/run/user/$(id -u)

## find dupes by name

    find . -type f -iname *.ext | xargs basename -a > names
    cat names | wc -l
    cat names | sort | uniq | wc -l

## find dupes by md5sum

    find . -type f -iname *.ext | xargs md5sum | awk '{ print $1 }' > hashes
    cat hashes | wc -l
    cat hashes | sort | uniq | wc -l

## unquote url quoted lines in log

    tail -f logfile.txt | python3 -c "import urllib.parse; import sys; [sys.stdout.write(urllib.parse.unquote(line)) for line in sys.stdin]"

## centos 7 on debian 11 lxd

edit in /etc/default/grub:

    GRUB_CMDLINE_LINUX_DEFAULT="quiet systemd.unified_cgroup_hierarchy=false"

run

    sudo update-grub

## Remove submodules but keep files

https://stackoverflow.com/questions/26752481/remove-git-submodule-but-keep-files

    mv subfolder subfolder_tmp
    git submodule deinit subfolder
    git rm --cached subfolder
    mv subfolder_tmp subfolder
    git add subfolder

## Get chrome history

https://superuser.com/questions/602252/can-chrome-browser-history-be-exported-to-an-html-file

    cp ./.config/chromium/Default/History History
    sqlite3 History
    sqlite> .headers on
    sqlite> .mode csv
    sqlite> .output my-history.csv
    sqlite> SELECT url FROM urls ORDER BY last_visit_time DESC

## Disable ipv6

    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

## Run docker in lxd

```
lxc config set CONTAINER-NAME security.nesting=true security.syscalls.intercept.mknod=true security.syscalls.intercept.setxattr=true
```

## Build/Install emacs 28.2 on centos 7

```
wget https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/emacs/emacs-28.2.tar.xz
tar xf emacs-28.2.tar.xz
cd emacs-28.2
yum install gcc gnutls-devel ncurses-devel
./configure
sudo make install
```

## emacs No space left on device errors

```
echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p
```

## Missing libraries for mongo on Ubuntu 22.04+

```
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
```

reference: https://stackoverflow.com/questions/72133316/ubuntu-22-04-libssl-so-1-1-cannot-open-shared-object-file-no-such-file-or-di
