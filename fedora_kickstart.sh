# Fedora Kickstart

if [ ! -d "$HOME/.ssh" ]; then
    echo "Set up your ssh keypair."
    exit
fi

# Trackpoint fix (Lenovo laptop only)
# echo -e '\nalias tp="sudo $HOME/.tpoint_fix"' >> ~/.bashrc
# echo 'echo 255 > /sys/devices/platform/i8042/serio1/serio2/speed' > ~/.tpoint_fix
# chmod 100 ~/.tpoint_fix

echo -e "\n=== Updating system and installing essential packages ==="
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf update -y

# Basic goodies
sudo dnf install -y numix-icon-theme-circle arc-theme \
    mariadb-server postgresql-server libpq-devel \
    ffmpeg ffmpeg-devel ffmpegthumbnailer vlc \
    git neovim gcc-c++ cmake make automake kernel-devel mailx postfix \
    java-latest-openjdk-devel java-latest-openjdk-src \
    dconf-editor gnome-tweaks transmission-gtk htop ncdu pv exa autojump \
    dnscrypt-proxy nodejs

# gstreamer plugin for video playback
sudo dnf install -y gstreamer1 gstreamer1-libav

echo -e "\n=== Removing unnecessary packages ==="
sudo dnf remove -y gnome-boxes gnome-calendar gnome-clocks gnome-contacts gnome-maps gnome-photos gnome-weather cheese

echo -e "\n=== Miscellaneous configuration ==="

# Change default thumbnailer
cd /usr/share/thumbnailers
sudo mv -n totem.thumbnailer totem.thumbnailer.old
sudo ln -sf ffmpegthumbnailer.thumbnailer totem.thumbnailer
cd ~

# Randomize MAC address every time you connect to WiFi
echo "[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
connection.stable-id=\${CONNECTION}/\${BOOT}" | sudo tee /etc/NetworkManager/conf.d/00-macrandomize.conf

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
echo "root:		$USER" | sudo tee -a /etc/aliases
sudo newaliases
sudo systemctl enable postfix
sudo systemctl start postfix

# vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo -e "\n=== Configuring git ==="
git config --global user.name "Luc Street"
git config --global user.email "lucis-fluxum@users.noreply.github.com"
git config --global core.editor "vi"

echo -e "\n=== Installing and configuring podman ==="
sudo dnf install -y podman podman-compose

echo -e "\n=== Downloading dotfiles ==="
rm -rf ~/.dotfiles_old
git clone --single-branch --branch master --recursive https://github.com/lucis-fluxum/dotfiles ~/.dotfiles
~/.dotfiles/setup.sh
mkdir -p ~/.config/nvim
ln -sf ~/.vimrc ~/.config/nvim/init.vim

echo -e "\n=== Grabbing a couple scripts ==="
sudo curl -o /etc/profile.d/korora_profile.sh \
    https://raw.githubusercontent.com/lucis-fluxum/kp-korora-extras/master/upstream/korora.sh
sudo chmod 644 /etc/profile.d/korora_profile.sh

sudo mkdir -p /usr/share/korora-extras
sudo curl -o /usr/share/korora-extras/dircolors.ansi-universal \
    https://raw.githubusercontent.com/lucis-fluxum/kp-korora-extras/master/upstream/dircolors.ansi-universal

sudo ln -sf ~/.dotfiles/update_tools.sh /etc/cron.daily/update-tools

echo -e "\n=== Installing rbenv/ruby-build ==="
sudo dnf install -y openssl-devel libyaml-devel libffi-devel readline-devel gdbm-devel ncurses-devel zlib-devel
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo -e "\n=== Installing latest stable ruby ==="
source ~/.bash_profile
sudo chown -hR $USER:$USER ~/.rbenv/
LATEST_RUBY_STABLE=$(rbenv install -l | grep -oP '^\s*\K\d\.\d+\.\d+(?!-dev|-pre|-rc).*' | tail -n 1)
rbenv install $LATEST_RUBY_STABLE && rbenv global $LATEST_RUBY_STABLE

echo -e "\n=== Installing latest stable python / poetry ==="
sudo dnf install -y bzip2-devel xz-devel sqlite sqlite-devel tk-devel python3-devel
sudo chown -hR $USER:$USER ~/.pyenv/
LATEST_PYTHON_STABLE=$(pyenv install -l | grep -oP '^\s*\K\d\.\d+\.\d+(?!-dev|-pre|-rc).*' | tail -n 1)
pyenv install $LATEST_PYTHON_STABLE && pyenv global $LATEST_PYTHON_STABLE
pip install --upgrade pip
pip install poetry
poetry config virtualenvs.path ~/.venvs

echo -e "\n=== Installing yarn ==="
curl -o- -L https://yarnpkg.com/install.sh | bash

echo -e "\n=== Extra setup for neovim ==="
pip install neovim
gem install neovim

echo -e "\n=== Installing rust ==="
curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path --default-host x86_64-unknown-linux-gnu --default-toolchain stable
source ~/.cargo/env
rustup component add rust-src rustfmt clippy
cargo install cargo-audit cargo-fix cargo-outdated cargo-update ripgrep tokei

sudo chown -hR $USER:$USER ~/
sudo rm -rf /tmp/*

echo -e "\n=== All set up! ==="
