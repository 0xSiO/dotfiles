# Fedora Kickstart

if [ -z "$SUDO_USER" ]; then
    echo "Run this script using sudo bash $0"
    exit 1
fi

export HOME="/home/$SUDO_USER"

echo -e "\n=== Removing unnecessary packages ==="
dnf remove -y gnome-boxes gnome-calendar gnome-clocks gnome-contacts gnome-maps gnome-weather

echo -e "\n=== Updating system and installing essential packages ==="
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo

dnf update -y
systemctl daemon-reload

# RPM Fusion multimedia tweaks
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf install -y intel-media-driver

# Basic goodies
dnf install -y alacritty aria2 bat clang cronie-anacron fd-find ffmpegthumbnailer \
    file-roller file-roller-nautilus firewall-config git-delta gnome-tweaks htop mpv mullvad-vpn \
    ncdu neovim numix-icon-theme-circle parallel postfix postgresql-server postgresql-contrib \
    puddletag pv qbittorrent restic ripgrep s-nail tokei tmux uv zoxide zsh

echo -e "\n=== Miscellaneous configuration ==="

# Change default shell to zsh
chsh -s /bin/zsh $SUDO_USER

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

# Fix random audio cutoffs
mkdir ~/.config/pipewire/pipewire.conf.d
echo "context.properties = {
    default.clock.quantum     = 2048
    default.clock.min-quantum = 1024
    default.clock.max-quantum = 4096
}" > ~/.config/pipewire/pipewire.conf.d/00-increase-quantum.conf

# Bookmarks
echo "file://$HOME/Documents
file://$HOME/Music
file://$HOME/Pictures
file://$HOME/Videos
file://$HOME/Downloads
file://$HOME/Development Development" > ~/.config/gtk-3.0/bookmarks

# Install Sauce Code Pro Nerd Font
SCP_FONT_PATH=~/.local/share/fonts/SauceCodePro.tar.xz
curl --create-dirs -Lo $SCP_FONT_PATH https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.tar.xz
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

echo -e "\n=== Downloading dotfiles ==="
rm -rf ~/.dotfiles_old
git clone --single-branch --branch master --recursive https://github.com/0xSiO/dotfiles ~/.dotfiles
~/.dotfiles/setup.sh linux
mkdir /etc/cron.daily
ln -sf ~/.dotfiles/linux/update_tools.sh /etc/cron.daily/update-tools

echo -e "\n=== Installing asdf & plugins ==="
ASDF_PATH=~/.local/bin/asdf.tar.gz
ASDF_VERSION=0.17.0
curl --create-dirs -Lo $ASDF_PATH https://github.com/asdf-vm/asdf/releases/download/v$ASDF_VERSION/asdf-v$ASDF_VERSION-linux-amd64.tar.gz 
tar -xvf $ASDF_PATH -C ~/.local/bin
rm $ASDF_PATH

dnf install -y autoconf gcc rust patch make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel gdbm-devel ncurses-devel perl-FindBin zlib-ng-compat-devel
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add golang
asdf install

echo -e "\n=== Installing rust ==="
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --default-host $(arch)-unknown-linux-gnu --default-toolchain stable -c rust-src
source ~/.cargo/env
dnf install -y openssl-devel
cargo install cargo-audit cargo-outdated cargo-update eza

chown -hR $SUDO_USER:$SUDO_USER ~/

echo -e "\n=== All set up! ==="
