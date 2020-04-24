# Fedora Kickstart

if [ -z "$SUDO_USER" ]; then
    echo "Run this script using sudo bash $0"
    exit
fi

export HOME="/home/$SUDO_USER"

if [ ! -d "$HOME/.ssh" ]; then
    echo "Set up your ssh keypair."
    exit
fi

echo -e "\n=== Updating system and installing essential packages ==="
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf update -y
systemctl daemon-reload

# Basic goodies
dnf install -y numix-icon-theme-circle arc-theme mariadb-server postgresql-server libpq-devel ffmpeg \
    ffmpeg-devel ffmpegthumbnailer vlc git neovim gcc-c++ cmake make automake kernel-devel mailx postfix \
    avahi anacron podman podman-compose dconf-editor gnome-tweaks transmission-gtk htop ncdu pv exa \
    autojump dnscrypt-proxy

systemctl enable avahi-daemon

# gstreamer plugin for video playback
dnf install -y gstreamer1 gstreamer1-libav

echo -e "\n=== Removing unnecessary packages ==="
dnf remove -y gnome-boxes gnome-calendar gnome-clocks gnome-contacts gnome-maps gnome-photos gnome-weather cheese

echo -e "\n=== Miscellaneous configuration ==="

# Change default thumbnailer
cd /usr/share/thumbnailers
mv -n totem.thumbnailer totem.thumbnailer.old
ln -sf ffmpegthumbnailer.thumbnailer totem.thumbnailer
cd ~

# Randomize MAC address every time you connect to WiFi
echo "[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
connection.stable-id=\${CONNECTION}/\${BOOT}" | tee /etc/NetworkManager/conf.d/00-macrandomize.conf

# Bookmarks
echo "file://$HOME/Documents
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Downloads
file://$HOME/Development Development
file://$HOME/MEGA/Books Textbooks" > ~/.config/gtk-3.0/bookmarks

# Reload fonts
fc-cache -r

# Mail redirection
echo "root:		$SUDO_USER" | tee -a /etc/aliases
newaliases
systemctl enable postfix
systemctl start postfix

# vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo -e "\n=== Configuring git ==="
git config --global user.name "Luc Street"
git config --global user.email "lucis-fluxum@users.noreply.github.com"
git config --global core.editor "vi"

echo -e "\n=== Downloading dotfiles ==="
rm -rf ~/.dotfiles_old
git clone --single-branch --branch master --recursive https://github.com/lucis-fluxum/dotfiles ~/.dotfiles
~/.dotfiles/setup.sh
mkdir -p ~/.config/nvim
ln -sf ~/.vimrc ~/.config/nvim/init.vim

echo -e "\n=== Grabbing a couple scripts ==="
curl -o /etc/profile.d/korora_profile.sh \
    https://raw.githubusercontent.com/lucis-fluxum/kp-korora-extras/master/upstream/korora.sh
chmod 644 /etc/profile.d/korora_profile.sh

mkdir -p /usr/share/korora-extras
curl -o /usr/share/korora-extras/dircolors.ansi-universal \
    https://raw.githubusercontent.com/lucis-fluxum/kp-korora-extras/master/upstream/dircolors.ansi-universal

ln -sf ~/.dotfiles/update_tools.sh /etc/cron.daily/update-tools

echo -e "\n=== Installing rbenv/ruby-build ==="
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo -e "\n=== Installing latest stable ruby ==="
dnf install -y bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
source ~/.bash_profile
chown -hR $SUDO_USER:$SUDO_USER ~/.rbenv/
LATEST_RUBY_STABLE=$(rbenv install -l | grep -oP '^\s*\K\d\.\d+\.\d+(?!-dev|-pre|-rc).*' | tail -n 1)
rbenv install $LATEST_RUBY_STABLE && rbenv global $LATEST_RUBY_STABLE

echo -e "\n=== Installing latest stable python / poetry ==="
dnf install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel \
    libffi-devel findutils python3-devel
chown -hR $SUDO_USER:$SUDO_USER ~/.pyenv/
LATEST_PYTHON_STABLE=$(pyenv install -l | grep -oP '^\s*\K\d\.\d+\.\d+(?!-dev|-pre|-rc|a).*' | tail -n 1)
pyenv install $LATEST_PYTHON_STABLE && pyenv global $LATEST_PYTHON_STABLE
pip install --upgrade pip
pip install poetry
poetry config virtualenvs.path ~/.venvs

echo -e "\n=== Installing latest nvm / node ==="
chown -hR $SUDO_USER:$SUDO_USER ~/.nvm/
NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
LATEST_NODE=$(nvm ls-remote | tail -n1 | grep -oP 'v\d+\.\d+\.\d+')
nvm install $LATEST_NODE
nvm alias default $LATEST_NODE
nvm use --delete-prefix default

echo -e "\n=== Installing yarn ==="
npm install -g yarn

echo -e "\n=== Extra setup for neovim ==="
pip install neovim
gem install neovim

echo -e "\n=== Installing rust ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y --no-modify-path --default-host $(arch)-unknown-linux-gnu --default-toolchain stable
source ~/.cargo/env
rustup component add rust-src
cargo install cargo-audit cargo-outdated cargo-update ripgrep tokei

chown -hR $SUDO_USER:$SUDO_USER ~/
rm -rf /tmp/*

echo -e "\n=== All set up! ==="
