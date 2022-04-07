# desktop

Set up a desktop with ansible

<table>
    <tr>
        <td><img src="https://i.imgur.com/XfdJyYP.png"></td>
        <td><img src="https://i.imgur.com/hqS89hh.png"></td>
    </tr>
</table>

## Requirements

Tested on:

- Ubuntu 21.10
- Ubuntu 22.04
- Debian 11

## Options

Set environmental variables to configure the playbook:

- AUTOLOGIN=true/false

automatically log in to the i3 desktop. Useful with encrypted disks or VMs.

- USER

Your username on the system

- FONT_SIZE

Default for size for GTK and kitty

- DPI

DPI setting for X11 and Xft (default is 96. To make everything eg. twice as big, use 192)

## Running

    sudo apt update
    sudo apt install git ansible
    git clone https://github.com/dvolk/desktop
    cd desktop
    AUTOLOGIN=true USER=dv FONT_SIZE=12 DPI=96 ansible-playbook -K setup.yml
