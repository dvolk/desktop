# desktop

Set up a perculiar desktop system with ansible

<img src="https://i.imgur.com/k8RlwOt.png">

## Requirements

- Debian 11

## Running

    sudo apt update
    sudo apt install git ansible
    git clone https://github.com/dvolk/desktop
    cd desktop
    AUTOLOGIN=true USER=dv FONT_SIZE=12 DPI=96 ansible-playbook -K setup.yml
