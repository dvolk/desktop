# desktop

Set up a desktop with ansible

<table>
    <tr>
        <td><img src="https://i.imgur.com/XfdJyYP.png"></td>
        <td><img src="https://i.imgur.com/hqS89hh.png"></td>
    </tr>
</table>

## requirements

Tested on:

- Ubuntu 21.10
- Ubuntu 22.04
- Debian 11

## Running

    sudo apt update
    sudo apt install git ansible
    git clone https://github.com/dvolk/desktop
    cd desktop
    FONT_SIZE=12 DPI=96 ansible-playbook -K setup.yml
