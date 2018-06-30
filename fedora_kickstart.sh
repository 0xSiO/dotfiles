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
dnf copr enable -y heliocastro/hack-fonts

dnf update -y

# Crystal repository
curl https://dist.crystal-lang.org/rpm/setup.sh | bash

# Basic goodies
dnf install -y numix-icon-theme-circle arc-theme hack-fonts \
    mongodb mongodb-server mariadb mariadb-server \
    ffmpeg ffmpeg-devel ffmpegthumbnailer gstreamer-ffmpeg vlc \
    neovim crystal cmake dconf-editor

# gstreamer plugins galore
dnf install -y gstreamer gstreamer-ffmpeg gstreamer-plugins-bad gstreamer-plugins-bad-free \
    gstreamer-plugins-bad-free-extras gstreamer-plugins-bad-nonfree gstreamer-plugins-base \
    gstreamer-plugins-good gstreamer-plugins-good-extras gstreamer-plugins-ugly gstreamer-tools \
    gstreamer1-libav gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-freeworld \
    gstreamer1-plugins-good-extras gstreamer1-plugins-ugly gstreamer1-plugins-bad-free-fluidsynth \
    gstreamer1-plugins-bad-free-wildmidi gstreamer1-plugins-bad-nonfree gstreamer1-plugins-base-tools \
    gstreamer1-plugins-entrans gstreamer1-plugins-fc gstreamer1-rtsp-server gstreamer1-vaapi

# Change default thumbnailer
cd /usr/share/thumbnailers
mv -n totem.thumbnailer totem.thumbnailer.old
ln -s ffmpegthumbnailer.thumbnailer totem.thumbnailer
cd ~

# Glorious global dark theme
echo "[Settings]
gtk-application-prefer-dark-theme=1" > ~/.config/gtk-3.0/settings.ini

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

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo -e "\n=== Configuring git ==="
git config --global user.name "Luc Street"
git config --global user.email "lucis-fluxum@users.noreply.github.com"
git config --global core.editor "vi"

echo -e "\n=== Installing and configuring docker ==="
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf config-manager --set-enabled docker-ce-edge
dnf makecache
dnf install -y docker-ce docker-compose
systemctl start docker && systemctl enable docker
usermod -aG docker $SUDO_USER

echo -e "\n=== Downloading dotfiles ==="
rm -rf ~/.dotfiles_old
git clone --recursive git@github.com:lucis-fluxum/dotfiles.git ~/.dotfiles
~/.dotfiles/setup.sh
mkdir ~/.config/nvim
ln -sf $HOME/.vimrc $HOME/.config/nvim/init.vim

echo -e "\n=== Grabbing a couple scripts ==="
curl -o /etc/profile.d/korora_profile.sh \
    https://raw.githubusercontent.com/kororaproject/kp-korora-extras/master/upstream/korora.sh
chmod 644 /etc/profile.d/korora_profile.sh
curl -o /usr/share/korora-extras/dircolors.ansi-universal \
    https://raw.githubusercontent.com/kororaproject/kp-korora-extras/master/upstream/dircolors.ansi-universal
cp ~/.dotfiles/update_tools.sh /etc/cron.daily/update-tools

echo -e "\n=== Installing rbenv/ruby-build ==="
dnf install -y openssl-devel libyaml-devel libffi-devel readline-devel gdbm-devel ncurses-devel
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
nvm use --delete-prefix default
ln -sf $NVM_DIR/versions/node/$(nvm current)/bin/node /usr/local/bin/node

echo -e "\n=== Extra setup for neovim ==="
pip install --user neovim && pip3 install --user neovim
gem install neovim
npm install -g neovim

echo -e "\n=== Installing rust ==="
curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path --default-host x86_64-unknown-linux-gnu --default-toolchain nightly
cargo install cargo-update cargo-outdated cargo-fix ripgrep tokei

chown -hR $SUDO_USER:$SUDO_USER ~/
rm -rf /tmp/*

echo -e "\n=== All set up! ==="
