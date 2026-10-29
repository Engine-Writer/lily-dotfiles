#!/usr/bin/env bash
set -Eeuo pipefail

run() {
    printf '==> %s\n' "$*"
    "$@"
}

PACMAN_DEPS=(
    hyprland
    hyprpaper
    xdg-desktop-portal-hyprland
    kitty
    dolphin
    github-cli
    swaync
    copyq
    grim
    slurp
    inotify-tools
    easyeffects
    zellij
    ttf-jetbrains-mono-nerd
    pipewire
    pipewire-alsa
    pipewire-pulse
    waybar
    wireplumber
    brightnessctl
    playerctl
    polkit-gnome
    kwallet-pam
    corectrl
    wl-clipboard
    xorg-xrandr
    jq
    git
    xdg-user-dirs
    neovim
    vim
    zsh
    starship
    helix
    fastfetch
    pyright
    clang
    lua-language-server
    rust-analyzer
    nodejs
    npm
)

AUR_DEPS=(
    ulauncher
    visual-studio-code-bin
)

FLATPAK_DEPS=(
    org.equicord.equibop
)

run sudo pacman -S --needed --noconfirm "${PACMAN_DEPS[@]}"

npm_prefix="$HOME/.local"
export PATH="$npm_prefix/bin:$PATH"
run npm install --global --prefix "$npm_prefix" typescript typescript-language-server

ZSH_PATH=$(command -v zsh || true)

if [[ -n "$ZSH_PATH" ]]; then
    if ! grep -qx "$ZSH_PATH" /etc/shells; then
        printf '%s\n' "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    if [[ "${SHELL:-}" != "$ZSH_PATH" ]]; then
        run chsh -s "$ZSH_PATH"
    else
        echo "==> zsh is already the default shell"
    fi
else
    echo "==> zsh installation failed"
fi

build_aur_pkg() (
    local pkg="$1"
    local tmpdir
    tmpdir=$(mktemp -d)
    trap 'rm -rf -- "$tmpdir"' EXIT
    run git clone "https://aur.archlinux.org/$pkg.git" "$tmpdir/$pkg"
    (cd -- "$tmpdir/$pkg" && run makepkg -si --noconfirm)
)

AUR_HELPER=""

if command -v yay >/dev/null; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null; then
    AUR_HELPER="paru"
else
    echo "==> No AUR helper found, bootstrapping yay"
    run sudo pacman -S --needed --noconfirm base-devel
    build_aur_pkg yay
    if command -v yay >/dev/null; then
        AUR_HELPER="yay"
    fi
fi

aur_install() {
    local pkg="$1"
    if [ -n "$AUR_HELPER" ]; then
        run "$AUR_HELPER" -S --needed --noconfirm "$pkg"
    else
        echo "==> No AUR helper available, building $pkg manually"
        build_aur_pkg "$pkg"
    fi
}

for pkg in "${AUR_DEPS[@]}"; do
    aur_install "$pkg"
done

if ! command -v flatpak >/dev/null 2>&1; then
    run sudo pacman -S --needed --noconfirm flatpak
fi

run flatpak remote-add --user --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo

for pkg in "${FLATPAK_DEPS[@]}"; do
    run flatpak install --user --noninteractive --or-update flathub "$pkg"
done

printf '==> Installing Zen Browser\n'
zen_script=$(mktemp)
trap 'rm -f -- "$zen_script"' EXIT
run curl -fsSL -o "$zen_script" https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh
run sh "$zen_script"

mkdir -p -- "$HOME/Downloads"
run xdg-user-dirs-update
run flatpak override --user --filesystem=xdg-download org.equicord.equibop

printf '==> Setup complete\n'
printf '==> Default shell: %s\n' "$ZSH_PATH"
printf '==> Log out and back in for zsh to apply\n'
