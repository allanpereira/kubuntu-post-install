#!/bin/bash

set -e

USER=$(getent passwd $SUDO_USER | cut -d: -f1)
HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

REPO="https://raw.githubusercontent.com/allanpereira/kubuntu-post-install/main"
ZSH_THEME="powerlevel10k/powerlevel10k"

function print {
  echo -e "\n\033[1m$1\033[0m"
}

function makedir {
  mkdir -p $1
  chown -R $USER:$USER $1
}

function makefile {
  touch $1
  chown $USER:$USER $1
}

if [ "$EUID" -ne 0 ]
  then echo "You should run this script as root. Exiting."
  exit
fi


print "Creating directories..."
cd $HOME
makedir programs
makedir repos
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

# gcloud CLI
curl -fsSLo /usr/share/keyrings/cloud.google.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list'
wget -qO- https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor > /usr/share/keyrings/cloud.google.gpg

# PHP
add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1

# Papirus Icon Theme
add-apt-repository -y ppa:papirus/papirus > /dev/null 2>&1


print "Downloading DisplayLink USB TO DVI Driver..."
wget -q --show-progress https://www.synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip

print "Downloading Source Code Pro Font..."
FONT_NAME="sourcecodepro"
wget -q --show-progress "https://github.com/adobe-fonts/source-code-pro/archive/1.017R.tar.gz" -O "`echo $FONT_NAME`.tar.gz"
tar --extract --gzip --file ${FONT_NAME}.tar.gz
rm -rf ${FONT_NAME}.tar.gz ${FONT_NAME}
mv source-code-pro* ${FONT_NAME}

print "Downloading WebStorm..."
if [ -z "$(ls -A $HOME/programs/webstorm)" ]; then
  wget -q --show-progress "https://download.jetbrains.com/webstorm/WebStorm-2023.1.tar.gz" -O "webstorm.tar.gz"
  tar --extract --gzip --file webstorm.tar.gz
  rm -rf webstorm.tar.gz
  mv WebStorm-* webstorm
else
  echo -e "Already installed, skipping."
fi


print "Installing APT packages..."
apt update
apt install -y \
    php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath \
    openjdk-17-jdk openjdk-17-jre \
    npm nodejs \
    git git-gui gitk git-flow \
    code vim \
    google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin kubectl \
    fonts-inconsolata fonts-roboto \
    papirus-icon-theme \
    brave-browser filezilla \
    guake gdebi-core gnome-keyring kolourpaint jq qemu-kvm unzip xclip zsh

print "Installing Snap packages..."
snap install discord
snap install spotify

print "Installing NPM global packages..."
npm install -g n yarn pnpm

print "Installing DisplayLink USB TO DVI Driver..."
apt -qq install -y cpp-12 dctrl-tools dkms gcc-12 libasan8 libdrm-dev libgcc-12-dev libpciaccess-dev libtsan2
unzip -o 'DisplayLink USB Graphics Software for Ubuntu5.6.1-EXE.zip'
chmod +x displaylink-driver-5.6.1-59.184.run
./displaylink-driver-5.6.1-59.184.run

print "Installing Source Code Pro Font..."
makedir /usr/share/fonts/truetype/$FONT_NAME
cp -R /tmp/$FONT_NAME/* /usr/share/fonts/truetype/$FONT_NAME/
rm -rf /tmp/$FONT_NAME

if [ -z "$(ls -A $HOME/programs/webstorm)" ]; then
  print "Installing WebStorm..."
  makedir $HOME/programs/webstorm/
  cp -R /tmp/webstorm/* $HOME/programs/webstorm/
  rm -rf /tmp/webstorm
fi

print "Installing Node 18..."
n 18.16.0

print "Installing Oh My Zsh..."
rm -rf $HOME/.oh-my-zsh
yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

print "Installing Powerlevel10k theme for Zsh..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

print "Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/k
echo "source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc


print "Registering Git Aliases..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.up "pull origin --rebase"
git config --global alias.dlog "log --all --decorate --oneline --graph"

print "Changing Git default text editor..."
git config --global core.editor "vim"

print "Changing Git default branch name..."
git config --global init.defaultBranch main

print "Changing Git autoSetupRemote config..."
git config --global push.autoSetupRemote true

print "Setting ZSH as default shell..."
chsh -s "$(which zsh)"
usermod -s "$(which zsh)" $USER

print "Setting Brave as default browser..."
update-alternatives --set x-www-browser /usr/bin/brave-browser-stable

print "Registering system aliases..."
makefile $HOME/.aliases
wget -O $HOME/.aliases $REPO/.aliases

print "Downloading application launcher icon..."
makedir $HOME/Pictures
wget -q --show-progress -O $HOME/Pictures/ic_dashboard_white_48dp.png $REPO/assets/images/ic_dashboard_white_48dp.png

print "Setting zsh theme..."
sed -i "s|ZSH_THEME=.*|ZSH_THEME=\"$ZSH_THEME\"|" $HOME/.zshrc

print "Setting zsh plugins..."
sed -i "s|plugins=.*|plugins=(colorize docker git jsontools kubectl k zsh-autosuggestions zsh-syntax-highlighting)|" $HOME/.zshrc

print "Writing environment variables export..."
makefile $HOME/.bash_profile
makefile $HOME/.zshenv
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=$HOME/android/sdk
export ANDROID_SDK_ROOT=$HOME/android/sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"' | tee $HOME/.bash_profile > $HOME/.zshenv

print "Creating desktop entries..."
for file in assets/desktop-entries/*.desktop
do
    envsubst < "$file" > "$HOME/Desktop/$(basename $file)"
done

print "Updating font cache..."
fc-cache -f