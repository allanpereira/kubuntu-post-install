#!/bin/bash

set -e

USER=$(getent passwd $SUDO_USER | cut -d: -f1)
HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

function print {
    echo -e "\n\033[1m$1\033[0m"
}

if [ "$EUID" -ne 0 ]
  then echo "You should run this script as root. Exiting."
  exit
fi


print "Creating directories..."
cd $HOME
mkdir -p programs
mkdir -p repos
cd /tmp


print "Installing base packages..."
apt -qq update && apt -qq install -y lsb-release ca-certificates apt-transport-https curl software-properties-common


print "Adding repositories..."
# Brave
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list'

# VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# PHP
add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1


print "Downloading DisplayLink USB TO DVI Driver..."
wget -q --show-progress https://www.synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip

print "Downloading Source Code Pro Font..."
FONT_NAME="sourcecodepro"
wget -q --show-progress "https://github.com/adobe-fonts/source-code-pro/archive/1.017R.tar.gz" -O "`echo $FONT_NAME`.tar.gz"
tar --extract --gzip --file ${FONT_NAME}.tar.gz
rm -rf ${FONT_NAME}.tar.gz ${FONT_NAME}
mv source-code-pro* ${FONT_NAME}

print "Downloading WebStorm..."
wget -q --show-progress "https://download.jetbrains.com/webstorm/WebStorm-2023.1.tar.gz" -O "webstorm.tar.gz"
tar --extract --gzip --file webstorm.tar.gz
rm -rf webstorm.tar.gz
mv WebStorm-* webstorm


print "Installing APT packages..."
apt update
apt install -y \
    php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath \
    openjdk-17-jdk openjdk-17-jre \
    npm nodejs \
    git git-gui gitk git-flow \
    code vim \
    fonts-inconsolata fonts-roboto \
    brave-browser filezilla \
    guake gdebi-core gnome-keyring jq qemu-kvm unzip zsh

print "Installing Snap packages..."
snap install discord
snap install icon-theme-papirus
snap install spotify

print "Installing NPM global packages..."
npm install -g n yarn pnpm

print "Installing DisplayLink USB TO DVI Driver..."
apt -qq install -y cpp-12 dctrl-tools dkms gcc-12 libasan8 libdrm-dev libgcc-12-dev libpciaccess-dev libtsan2
unzip -o 'DisplayLink USB Graphics Software for Ubuntu5.6.1-EXE.zip'
chmod +x displaylink-driver-5.6.1-59.184.run
./displaylink-driver-5.6.1-59.184.run

print "Installing Source Code Pro Font..."
mkdir -p /usr/share/fonts/truetype/$FONT_NAME
cp -R /tmp/$FONT_NAME/* /usr/share/fonts/truetype/$FONT_NAME/
rm -rf /tmp/$FONT_NAME

print "Installing WebStorm..."
mkdir -p $HOME/programs/webstorm/
cp -R /tmp/webstorm/* $HOME/programs/webstorm/
rm -rf /tmp/webstorm

print "Installing Oh My Zsh..."
rm -rf $HOME/.oh-my-zsh
yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


print "Registering Git Aliases..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

print "Setting ZSH as default shell..."
chsh -s $(which zsh)

print "Setting Brave as default browser..."
update-alternatives --set x-www-browser /usr/bin/brave-browser-stable

print "Updating font cache..."
fc-cache -f
