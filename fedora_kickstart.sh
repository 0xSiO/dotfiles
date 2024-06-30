# Fedora Kickstart

if [ -z "$SUDO_USER" ]; then
    echo "Run this script using sudo bash $0"
    exit 1
fi

export HOME="/home/$SUDO_USER"

echo -e "\n=== Removing unnecessary packages ==="
dnf remove -y gnome-boxes gnome-calendar gnome-clocks gnome-contacts gnome-maps gnome-photos gnome-weather cheese

echo -e "\n=== Updating system and installing essential packages ==="
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf update -y
systemctl daemon-reload

# RPM Fusion multimedia tweaks
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf install -y intel-media-driver

# Basic goodies
dnf install -y anacron aria2 autojump-zsh bat cmake eza fd-find ffmpeg-devel ffmpegthumbnailer file-roller \
    file-roller-nautilus firewall-config gcc-c++ git-delta gnome-tweaks htop kernel-devel libpq-devel megasync \
    mpv ncdu neovim numix-icon-theme-circle postfix postgresql-server postgresql-contrib puddletag pv restic \
    ripgrep tokei transmission zsh

echo -e "\n=== Miscellaneous configuration ==="

# Change default shell to zsh
lchsh $SUDO_USER <<< /bin/zsh

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
file://$HOME/Development Development" > ~/.config/gtk-3.0/bookmarks

# Install Sauce Code Pro Nerd Font
SCP_FONT_PATH=~/.local/share/fonts/SauceCodePro.tar.xz
curl --create-dirs -Lo $SCP_FONT_PATH https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/SourceCodePro.tar.xz
mkdir ~/.local/share/fonts/SauceCodePro
tar -xvf $SCP_FONT_PATH -C ~/.local/share/fonts/SauceCodePro
rm $SCP_FONT_PATH

# Reload fonts
fc-cache -r

# Mail redirection
echo "root:		$SUDO_USER" >> /etc/aliases
newaliases
systemctl enable postfix
systemctl start postfix

echo -e "\n=== Installing asdf ==="
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

echo -e "\n=== Downloading dotfiles ==="
rm -rf ~/.dotfiles_old
git clone --single-branch --branch master --recursive https://github.com/0xSiO/dotfiles ~/.dotfiles
~/.dotfiles/setup.sh linux
mkdir /etc/cron.daily
ln -sf ~/.dotfiles/linux/update_tools.sh /etc/cron.daily/update-tools

source ~/.asdf/asdf.sh

echo -e "\n=== Installing latest stable ruby ==="
dnf install -y autoconf patch make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
asdf plugin add ruby
asdf install ruby latest
asdf global ruby latest

if [ $? -eq 0 ]; then
    gem install solargraph
    asdf reshim
else
    exit 3
fi

echo -e "\n=== Installing latest stable python / poetry ==="
dnf install -y make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2
asdf plugin add python
asdf install python latest
asdf global python latest

if [ $? -eq 0 ]; then
    pip install --upgrade pip wheel
    pip install poetry pynvim
    asdf reshim
    poetry config virtualenvs.path ~/.venvs
else
    exit 4
fi

echo -e "\n=== Installing latest nodejs ==="
asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest

if [ $? -eq 0 ]; then
    npm install -g npm
    asdf reshim
else
    exit 5
fi

echo -e "\n=== Installing rust ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --default-host $(arch)-unknown-linux-gnu --default-toolchain stable -c rust-src
source ~/.cargo/env
cargo install cargo-audit cargo-outdated cargo-update

chown -hR $SUDO_USER:$SUDO_USER ~/
rm -rf /tmp/*

echo -e "\n=== All set up! ==="
