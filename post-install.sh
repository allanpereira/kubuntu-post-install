if [ "$EUID" -ne 0 ]
  then echo "You should run this script as root. Exiting."
  exit
fi


echo "Creating directories..."
cd ~
mkdir programs
mkdir repos
cd /tmp


echo "Installing base packages..."
apt install apt-transport-https curl libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 -y


echo "Adding Brave Browser Repository..."
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list

echo "Adding VSCode Repository..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

echo "Adding PHP Repository..."
add-apt-repository -y ppa:ondrej/php

echo "Downloading DisplayLink USB TO DVI Driver..."
wget -q https://www.synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip

echo "Downloading Source Code Pro Font..."
FONT_NAME="SourceCodePro"
mkdir /tmp/$FONT_NAME
cd /tmp/$FONT_NAME
wget -q "https://github.com/adobe-fonts/source-code-pro/archive/1.017R.tar.gz" -O "`echo $FONT_NAME`.tar.gz"
tar --extract --gzip --file ${FONT_NAME}.tar.gz
mkdir /usr/share/fonts/truetype/$FONT_NAME
cd ~


echo "Installing APT packages..."
apt update
apt install -y \
    php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath \
    openjdk-11-jre \
    npm nodejs \
    git git-gui gitk git-flow \
    fonts-inconsolata fonts-roboto \
    brave-browser filezilla unzip guake code gdebi-core zsh vim qemu-kvm software-properties-common gnome-keyring

echo "Installing Snap packages..."
snap install discord
snap install spotify
snap install icon-theme-papirus

echo "Installing NPM global packages..."
npm install -g n yarn pnpm

echo "Installing DisplayLink USB TO DVI Driver..."
unzip 'DisplayLink USB Graphics Software for Ubuntu5.6.1-EXE.zip'
chmod +x displaylink-driver-5.6.1-59.184.run
./displaylink-driver-5.6.1-59.184.run

echo "Installing Source Code Pro Font..."
cp -rf /tmp/$FONT_NAME/. /usr/share/fonts/truetype/$FONT_NAME/.
rm -rf /tmp/$FONT_NAME

echo "Installing WebStorm..."
wget -q "https://download.jetbrains.com/webstorm/WebStorm-2023.1.tar.gz" -O "webstorm.tar.gz"
tar --extract --gzip --file webstorm.tar.gz
rm -rf webstorm.tar.gz
mv WebStorm* ~/programs/webstorm

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


echo "Registering Git Aliases..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

echo "Setting ZSH as default shell..."
chsh -s $(which zsh)

echo "Setting Brave as default browser..."
update-alternatives --set x-www-browser /usr/bin/brave-browser-stable

echo "Updating font cache..."
fc-cache -fv


read -p "Set Papirus as Icon Theme. Press any key to continue..."
read -p "Set Breeze Snow as Cursor Theme. Press any key to continue..."