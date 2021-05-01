
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
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list

echo "Adding Spotify Repository..."
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list

echo "Adding VSCode Repository..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

echo "Downloading Discord package..."
wget -O ~/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"

echo "Downloading DisplayLink USB TO DVI Driver..."
wget https://www.synaptics.com/sites/default/files/exe_files/2021-04/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.4-EXE.zip

echo "Downloading Source Code Pro Font..."
FONT_NAME="SourceCodePro"
mkdir /tmp/$FONT_NAME
cd /tmp/$FONT_NAME
wget "https://github.com/adobe-fonts/source-code-pro/archive/1.017R.tar.gz" -O "`echo $FONT_NAME`.tar.gz"
tar --extract --gzip --file ${FONT_NAME}.tar.gz
mkdir /usr/share/fonts/truetype/$FONT_NAME


echo "Installing packages..."
apt update
apt install brave-browser filezilla unzip openjdk-11-jre guake git git-gui gitk code nodejs gdebi-core npm fonts-inconsolata fonts-roboto zsh vim -y

echo "Installing NPM global packages..."
npm install -g n yarn

echo "Installing Discord..."
gdebi ~/discord.deb
rm -rf discord.deb

echo "Installing DisplayLink USB TO DVI Driver..."
unzip 'DisplayLink USB Graphics Software for Ubuntu5.4-EXE.zip'
chmod +x displaylink-driver-5.4.0-55.153.run
./displaylink-driver-5.4.0-55.153.run

echo "Installing Source Code Pro Font..."
cp -rf /tmp/$FONT_NAME/. /usr/share/fonts/truetype/$FONT_NAME/.
rm -rf /tmp/$FONT_NAME


echo "Registering Git Aliases..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status


echo "Setting ZSH as default shell..."
chsh -s $(which zsh)

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


echo "Updating font cache..."
fc-cache -fv

read -p "Set Papirus as Icon Theme. Press any key to continue..."
read -p "Set Breeze Snow as Cursor Theme. Press any key to continue..."
read -p "Download and Install Android Studio. Press any key to continue..."
read -p "Download and Install Web Storm. Press any key to continue..."