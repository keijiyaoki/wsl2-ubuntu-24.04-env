#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    cat<<EOF
Usage: $0 default_user_name
EOF
    exit 1
fi

if $(grep -qs default /etc/wsl.conf); then
    cat<<EOF
already done !! (/etc/wsl.conf exists)
===
$(cat /etc/wsl.conf)
EOF
    exit 1
fi

default_user=$1
root_dir=$(dirname -- "${BASH_SOURCE[0]}")

# (1) update distribution

sudo apt update
sudo apt upgrade

# (2) Japanease environment (+ Nerd Font)

sudo apt install language-pack-ja fonts-noto-cjk-extra fcitx5-mozc unzip
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

hash -r

fontUrls=(
    "https://github.com/yuru7/HackGen/releases/download/v2.9.0/HackGen_v2.9.0.zip"
    "https://github.com/yuru7/Firge/releases/download/v0.3.0/Firge_v0.3.0.zip"
    "https://github.com/yuru7/moralerspace/releases/download/v1.0.1/MoralerspaceHW_v1.0.1.zip"
    "https://github.com/yuru7/PlemolJP/releases/download/v1.7.1/PlemolJP_v1.7.1.zip"
    "https://github.com/yuru7/udev-gothic/releases/download/v1.3.1/UDEVGothic_v1.3.1.zip"
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/NerdFontsSymbolsOnly.zip"
)
fontPatterns=(
    "*/HackGenConsole*"
    "*/FirgeConsole*"
    "*/*.ttf"
    "*/*/PlemolJPConsole*"
    "*/UDEVGothic-*"
    "*.ttf"
)

fontsDir="${HOME}/.local/share/fonts"
install -d ${fontsDir}

for i in ${!fontUrls[@]}; do
    url=${fontUrls[$i]}
    pattern=${fontPatterns[$i]}
    zfile=${url##*/}

    wget -O - ${url} > ${zfile}
    for f in $(zipinfo -1 ${zfile} "${pattern}"); do
        font=${f##*/}
        unzip -p ${zfile} ${f} > ${fontsDir}/${font}
    done
    rm -f ${zfile}
done

fc-cache -vf

# (3) desktop environment

sudo apt install gnome-themes-extra-data gnome-terminal nautilus file-roller evince eog

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close

# (4) emacs

sudo apt install emacs-pgtk emacs-mozc-bin fonts-symbola

emacsDir="${HOME}/.emacs.d"
install -d -m 700 ${emacsDir}
cp -f ${root_dir}/dot.emacs.d/early-init.el ${emacsDir}/
cp -f ${root_dir}/dot.emacs.d/init.el ${emacsDir}/
mkdir -p ${HOME}/ORG/doc

# (5) google-chrome

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmour -o /usr/share/keyrings/chrome-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'

sudo apt update
sudo apt install google-chrome-stable

# (6) ${HOME}/bin

install -d -m 700 ${HOME}/bin
install ${root_dir}/bin/* ${HOME}/bin/

cat <<"EOF" >> ${HOME}/.profile

. "$HOME/bin/setup-env.sh"
EOF

# (7) default user

sudo tee -a /etc/wsl.conf <<EOF >/dev/null

[user]
default = ${default_user}
EOF

# (8) workround Ubuntu 24.04 and WSLg: WSLg works only for uid=1000.

sudo usermod -aG $(id -nG ubuntu | cut -d " " --output-delimiter="," -f 1- -) ${default_user}

## swap ubuntu and default_user
u_Uid=$(id -u ubuntu)
u_Gid=$(id -g ubuntu)
d_Uid=$(id -u)
d_Gid=$(id -g)

cat<<EOF
swap ubuntu and ${defalut_user} uid and gid in /etc/passwd

ubuntu:x:${d_Uid}:${d_Gid}:...
${default_user}:x:${u_Uid}:${u_Gid}:...

EOF

read -p "Hit enter: "

sudo vipw

cat<<EOF
swap ubuntu and ${defalut_user} gid in /etc/group

ubuntu:x:${d_Gid}:${default_user}
${default_user}:x:${u_Gid}:

EOF

read -p "Hit enter: "

sudo vigr

cd /home
sudo chown -R ${d_Uid}:${d_Gid} ubuntu
sudo chown -R ${u_Uid}:${u_Gid} ${default_user}

# (9) reboot

cat<<EOF
initial setup done !!

exit Ubuntu-24.04 and run terminate distribution in PowerShell

> wsl --terminate Ubuntu-24.04
EOF
