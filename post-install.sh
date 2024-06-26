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
apt -qq update && apt -qq install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg \
  automake autoconf libncurses5-dev lsb-release unixodbc-dev

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

# Lens
curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | tee /etc/apt/sources.list.d/lens.list > /dev/null

# Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | tee /etc/apt/keyrings/docker.gpg > /dev/null
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# PHP
add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1

# Papirus Icon Theme
add-apt-repository -y ppa:papirus/papirus > /dev/null 2>&1

# Ruby
add-apt-repository -y ppa:rael-gc/rvm > /dev/null 2>&1
curl -fsSL https://rvm.io/mpapis.asc | gpg --import - > /dev/null
curl -fsSL https://rvm.io/pkuczynski.asc | gpg --import - > /dev/null


print "Downloading DisplayLink USB TO DVI Driver..."
if [ ! -d "/usr/src/evdi-1.12.0" ]; then
  wget -q --show-progress https://www.synaptics.com/sites/default/files/exe_files/2022-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.6.1-EXE.zip
else
  echo -e "Already installed, skipping."
fi

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

print "Downloading IntelliJ IDEA..."
if [ -z "$(ls -A $HOME/programs/intellij)" ]; then
  wget -q --show-progress "https://download.jetbrains.com/idea/ideaIU-2023.1.2.tar.gz" -O "intellij.tar.gz"
  tar --extract --gzip --file intellij.tar.gz
  rm -rf intellij.tar.gz
  mv idea* intellij
else
  echo -e "Already installed, skipping."
fi

print "Downloading RubyMine..."
if [ -z "$(ls -A $HOME/programs/rubymine)" ]; then
  wget -q --show-progress "https://download.jetbrains.com/ruby/RubyMine-2023.1.3.tar.gz" -O "rubymine.tar.gz"
  tar --extract --gzip --file rubymine.tar.gz
  rm -rf rubymine.tar.gz
  mv RubyMine* rubymine
else
  echo -e "Already installed, skipping."
fi

print "Downloading k9s..."
wget -q --show-progress "https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz" -O "k9s.tar.gz"
tar --extract --gzip --file k9s.tar.gz k9s
rm -rf k9s.tar.gz

print "Downloading Arduino IDE..."
if [ -z "$(ls -A $HOME/programs/arduino-ide)" ]; then
  wget -q --show-progress "https://downloads.arduino.cc/arduino-ide/nightly/arduino-ide_nightly-latest_Linux_64bit.zip" -O "arduino-ide.zip"
  unzip -o 'arduino-ide.zip'
  rm -rf arduino-ide.zip
  mv arduino-ide* arduino-ide
else
  echo -e "Already installed, skipping."
fi

print "Downloading AWS CLI..."
if [ -z "$(ls -A /usr/local/bin/aws)" ]; then
  wget -q --show-progress "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"
  unzip -o 'awscliv2.zip'
  rm -rf awscliv2.zip
else
  echo -e "Already installed, skipping."
fi


print "Installing APT packages..."
apt update
apt install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath \
    openjdk-17-jdk openjdk-17-jre \
    npm nodejs \
    rvm \
    git git-gui gitk git-flow \
    code vim \
    google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin kubectl lens \
    fonts-inconsolata fonts-roboto \
    papirus-icon-theme \
    brave-browser filezilla \
    duf guake gdebi-core gnome-keyring kolourpaint jq qemu-kvm scrcpy unzip xclip zsh

print "Installing Snap packages..."
snap install discord
snap install spotify
snap install kontena-lens --classic

print "Installing NPM global packages..."
npm install -g n yarn pnpm

print "Installing DisplayLink USB TO DVI Driver..."
apt -qq install -y cpp-12 dctrl-tools dkms gcc-12 libasan8 libdrm-dev libgcc-12-dev libpciaccess-dev libtsan2

if [ ! -d "/usr/src/evdi-1.12.0" ]; then
  unzip -o 'DisplayLink USB Graphics Software for Ubuntu5.6.1-EXE.zip'
  chmod +x displaylink-driver-5.6.1-59.184.run
  ./displaylink-driver-5.6.1-59.184.run
else
  echo -e "Already installed, skipping."
fi

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

if [ -z "$(ls -A $HOME/programs/intellij)" ]; then
  print "Installing IntelliJ IDEA..."
  makedir $HOME/programs/intellij/
  cp -R /tmp/intellij/* $HOME/programs/intellij/
  rm -rf /tmp/intellij
fi

if [ -z "$(ls -A $HOME/programs/rubymine)" ]; then
  print "Installing RubyMine..."
  makedir $HOME/programs/rubymine/
  cp -R /tmp/rubymine/* $HOME/programs/rubymine/
  rm -rf /tmp/rubymine
fi

if [ -z "$(ls -A $HOME/programs/arduino-ide)" ]; then
  print "Installing Arduino IDE..."
  makedir $HOME/programs/arduino-ide/
  cp -R /tmp/arduino-ide/* $HOME/programs/arduino-ide/
  rm -rf /tmp/arduino-ide
fi

if [ -z "$(ls -A /usr/local/bin/aws)" ]; then
  print "Installing AWS CLI..."
  sh -c './aws/install'
fi

print "Installing Node 18..."
n 18.16.0

print "Installing Oh My Zsh..."
rm -rf $HOME/.oh-my-zsh
yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chown -R $USER:$USER $HOME/.oh-my-zsh
chown $USER:$USER $HOME/.zshrc

print "Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc

print "Installing Powerlevel10k theme for Zsh..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
wget -q --show-progress -O $HOME/.p10k.zsh $REPO/assets/config/.p10k.zsh
chown $USER:$USER $HOME/.p10k.zsh
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$HOME/.zshrc"

print "Installing k9s..."
mv k9s /usr/bin/

print "Installing asdf..."
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.12.0
fi
echo ". $HOME/.asdf/asdf.sh" >> "$HOME/.bashrc"
echo ". $HOME/.asdf/completions/asdf.bash" >> "$HOME/.bashrc"
echo ". $HOME/.asdf/asdf.sh" >> "$HOME/.zshrc"

print "Installing Elixir..."
ASDF="bash $HOME/.asdf/asdf.sh"
$ASDF plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
$ASDF plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
$ASDF install erlang 24.3.4.12
$ASDF install elixir 1.15.0
$ASDF global erlang 24.3.4.12
$ASDF global elixir 1.15.0

print "Installing Ruby..."
sed 's/mozilla.DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/' -i /etc/ca-certificates.conf
update-ca-certificates
echo "source \"/etc/profile.d/rvm.sh\"" >> "$HOME/.zshrc"
rvm fix-permissions system; rvm fix-permissions user
rvm get stable
rvm autolibs enable
rvm pkg install openssl
rvm install 2.7.8 -C --with-openssl-dir="$rvm_path/usr"

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

print "Changing Git push config..."
git config --global push.default current

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
sed -i "s|plugins=.*|plugins=(asdf catimg colorize docker git jsontools kubectl zsh-autosuggestions zsh-syntax-highlighting)|" $HOME/.zshrc

print "Adding user to rvm group..."
usermod -a -G rvm $USER

print "Writing environment variables export..."
makefile $HOME/.bash_profile
makefile $HOME/.zshenv
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=$HOME/android/sdk
export ANDROID_SDK_ROOT=$HOME/android/sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"' | tee $HOME/.bash_profile > $HOME/.zshenv

print "Updating font cache..."
fc-cache -f