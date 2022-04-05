# desktop

Set up a desktop with ansible

## requirements

- Ubuntu

## running

    sudo apt update
    sudo apt install git ansible
    git clone https://github.com/dvolk/desktop
    cd desktop
    FONT_SIZE=12 DPI=96 ansible-playbook -K setup.yml
