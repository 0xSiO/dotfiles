# Fedora Kickstart

if [ -z "$SUDO_USER" ]; then
    echo "Run this script using sudo bash $0"
    exit 1
fi

export HOME="/home/$SUDO_USER"

if [ ! -d "$HOME/.ssh" ]; then
    echo "Set up your ssh keypair."
    exit 2
fi

echo -e "\n=== Updating system and installing essential packages ==="
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf update -y
systemctl daemon-reload

# Basic goodies
dnf install -y arc-theme numix-icon-theme-circle \
      avahi anacron ffmpegthumbnailer postfix \
      cmake ffmpeg-devel gcc-c++ git kernel-devel libpq-devel make neovim postgresql-server \
      autojump chromium-browser-privacy exa ffmpeg gnome-tweaks htop mailx ncdu podman \
      podman-compose pv transmission-gtk vlc

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
connection.stable-id=\${CONNECTION}/\${BOOT}" > /etc/NetworkManager/conf.d/00-macrandomize.conf

# Bookmarks
echo "file://$HOME/Documents
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Downloads
file://$HOME/Development Development
file://$HOME/MEGA/Books Books" > ~/.config/gtk-3.0/bookmarks

# Reload fonts
fc-cache -r

# Mail redirection
echo "root:		$SUDO_USER" >> /etc/aliases
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
git clone --single-branch --branch master --recursive https://github.com/lucis-fluxum/dotfiles.git ~/.dotfiles
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

source ~/.bash_profile

echo -e "\n=== Installing latest stable ruby ==="
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
dnf install -y bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
chown -hR $SUDO_USER:$SUDO_USER ~/.rbenv/
LATEST_RUBY_STABLE=$(rbenv install -l | grep -oP '^\s*\K\d\.\d+\.\d+(?!-dev|-pre|-rc).*' | tail -n 1)
rm -rf /tmp/*
rbenv install $LATEST_RUBY_STABLE && rbenv global $LATEST_RUBY_STABLE
if [ $? -eq 0 ]; then
    gem install neovim solargraph
else
    exit 3
fi

echo -e "\n=== Installing latest stable python / poetry ==="
dnf install -y zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel xz xz-devel libffi-devel
chown -hR $SUDO_USER:$SUDO_USER ~/.pyenv/
LATEST_PYTHON_STABLE=$(pyenv install -l | grep -oP '^\s*\K\d\.\d+\.\d+(?!-dev|-pre|-rc|a).*' | tail -n 1)
rm -rf /tmp/*
pyenv install $LATEST_PYTHON_STABLE && pyenv global $LATEST_PYTHON_STABLE
if [ $? -eq 0 ]; then
    pip install --upgrade pip
    pip install poetry neovim
    poetry config virtualenvs.path ~/.venvs
else
    exit 4
fi

echo -e "\n=== Installing latest nodejs / yarn ==="
cd ~/.nodenv && src/configure && make -C src
git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build
chown -hR $SUDO_USER:$SUDO_USER ~/.nodenv/
LATEST_NODE=$(nodenv install -l | grep -oP '^\s*\K\d+\.\d+\.\d+(?!-dev|-pre|-rc).*' | tail -n 1)
nodenv install $LATEST_NODE && nodenv global $LATEST_NODE
if [ $? -eq 0 ]; then
    npm install -g yarn
    yarn global add neovim
else
    exit 5
fi

echo -e "\n=== Installing rust ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y --no-modify-path --default-host $(arch)-unknown-linux-gnu --default-toolchain stable
source ~/.cargo/env
rustup component add rust-src
cargo install cargo-audit cargo-outdated cargo-update ripgrep tokei

chown -hR $SUDO_USER:$SUDO_USER ~/
rm -rf /tmp/*

echo -e "\n=== All set up! ==="
