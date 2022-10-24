# desktop

Set up a desktop with ansible

<img src="https://i.imgur.com/k8RlwOt.png">

## Requirements

Tested on:

- Ubuntu 22.04
- Debian 11

## Running

    sudo apt update
    sudo apt install git ansible
    git clone https://github.com/dvolk/desktop
    cd desktop
    AUTOLOGIN=true USER=dv FONT_SIZE=12 DPI=96 ansible-playbook -K setup.yml
