# Fedora Kickstart

if [ "$SUDO_COMMAND" != "/usr/bin/bash" ]; then
    echo "Run under sudo -E bash."
    exit
fi

if [ ! -d "$HOME/.ssh" ]; then
    echo "Set up your ssh keypair."
    exit
fi

# Trackpoint fix (Lenovo laptop only)
# echo -e '\nalias tp="sudo $HOME/.tpoint_fix"' >> ~/.bashrc
# echo 'echo 255 > /sys/devices/platform/i8042/serio1/serio2/speed' > ~/.tpoint_fix
# chmod 100 ~/.tpoint_fix

echo -e "\n=== Updating system and installing essential packages ==="
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf update -y

# Basic goodies
dnf install -y numix-icon-theme-circle arc-theme \
    mariadb mariadb-server postgresql postgresql-server \
    ffmpeg ffmpeg-devel ffmpegthumbnailer vlc \
    neovim gcc-c++ cmake make automake kernel-devel mailx postfix \
    java-latest-openjdk-devel java-latest-openjdk-src \
    dconf-editor gnome-tweaks transmission-gtk htop

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

# Glorious global dark theme
echo "[Settings]
gtk-application-prefer-dark-theme=1" > ~/.config/gtk-3.0/settings.ini

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
file://$HOME/Development/Ruby/webvanta webvanta
file://$HOME/MEGA/Books Textbooks" > ~/.config/gtk-3.0/bookmarks

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

echo -e "\n=== Installing and configuring docker ==="
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf makecache
dnf install -y docker-ce docker-compose
systemctl start docker && systemctl enable docker
usermod -aG docker $SUDO_USER

echo -e "\n=== Downloading dotfiles ==="
rm -rf ~/.dotfiles_old
git clone --recursive https://github.com/lucis-fluxum/dotfiles ~/.dotfiles
~/.dotfiles/setup.sh
mkdir ~/.config/nvim
ln -sf $HOME/.vimrc $HOME/.config/nvim/init.vim

echo -e "\n=== Grabbing a couple scripts ==="
curl -o /etc/profile.d/korora_profile.sh \
    https://raw.githubusercontent.com/lucis-fluxum/kp-korora-extras/master/upstream/korora.sh
chmod 644 /etc/profile.d/korora_profile.sh

mkdir /usr/share/korora-extras
curl -o /usr/share/korora-extras/dircolors.ansi-universal \
    https://raw.githubusercontent.com/lucis-fluxum/kp-korora-extras/master/upstream/dircolors.ansi-universal
cp ~/.dotfiles/update_tools.sh /etc/cron.daily/update-tools

echo -e "\n=== Installing rbenv/ruby-build ==="
dnf install -y openssl-devel libyaml-devel libffi-devel readline-devel gdbm-devel ncurses-devel zlib-devel
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo -e "\n=== Installing latest stable ruby ==="
source ~/.bash_profile
chown -hR $SUDO_USER:$SUDO_USER ~/.rbenv/
LATEST_RUBY_STABLE=$(rbenv install -l | grep -oP '\s+\K\d\.\d+\.\d+(?!-dev|-pre|-rc).*' | tail -n 1)
rbenv install $LATEST_RUBY_STABLE && rbenv global $LATEST_RUBY_STABLE

echo -e "\n=== Installing latest node.js ==="
chown -hR $SUDO_USER:$SUDO_USER ~/.nvm/
chmod +x ~/.nvm/nvm.sh
NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
LATEST_NODE=$(nvm ls-remote | tail -n1 | grep -oP 'v\d+\.\d+\.\d+')
nvm install $LATEST_NODE
nvm alias default $LATEST_NODE
nvm use --delete-prefix default
ln -sf $NVM_DIR/versions/node/$(nvm current)/bin/node /usr/local/bin/node
npm install -g typescript

echo -e "\n=== Extra setup for neovim ==="
pip install --user neovim && pip3 install --user neovim
gem install neovim
npm install -g neovim
nvim --headless +PlugClean +PlugUpdate +qa!

echo -e "\n=== Installing rust ==="
curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path --default-host x86_64-unknown-linux-gnu --default-toolchain stable
rustup component add rust-src rustfmt clippy
cargo install cargo-audit cargo-fix cargo-outdated cargo-update ripgrep tokei

chown -hR $SUDO_USER:$SUDO_USER ~/
rm -rf /tmp/*

echo -e "\n=== All set up! ==="
