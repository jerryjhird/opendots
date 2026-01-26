#!/usr/bin/env sh

shopt -s dotglob
TUNED_TARGET_PROFILE="throughput-performance"

cpid() {
    local src="$1"
    local dst="$2"

    if [[ -d "$src" ]]; then
        [[ ! -d "$dst" ]] && sudo mkdir -p "$dst"
        for f in "$src"/*; do
            cpid "$f" "$dst/${f##*/}"
        done
    else
        if [[ -e "$dst" ]]; then
            if ! cmp -s "$src" "$dst"; then
                sudo cp -i "$src" "$dst"
            else
                echo "skipping identical file $dst"
            fi
        else
            sudo cp -i "$src" "$dst"
        fi
    fi
}

ensurepkg() {
    local yn_flag=""

    if [[ "$1" == "-y" ]]; then
        yn_flag="-y"
        shift
    fi

    for pkg in "$@"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            echo "installing $pkg"
            sudo dnf install $yn_flag "$pkg"
        else
            echo "$pkg is already installed"
        fi
    done
}

# install eroot, ehome files
for f in eroot/*; do
    cpid "$f" "/${f#eroot/}"
done

for f in ehome/*; do
    cpid "$f" "$HOME/${f#ehome/}"
done

# ensure packages are installed
ensurepkg -y i3 rofi feh alacritty picom flameshot playerctl tuned mold

# change script permissions to executable
sudo chmod +x ~/.config/i3/scripts/wallpaper_manager.sh
sudo chmod +x ~/.config/i3/scripts/rofirun.sh

# tuned (performance optimization)
if systemctl is-active --quiet tuned; then
    echo "tuned is already running"
else
    sudo systemctl enable --now tuned
fi

TUNED_CURRENT_PROFILE=$(tuned-adm active | awk '{print $4}')

if [[ "$TUNED_CURRENT_PROFILE" != "$TUNED_TARGET_PROFILE" ]]; then
    sudo tuned-adm profile "$TUNED_TARGET_PROFILE"
else
    echo "tuned profile is already $TUNED_TARGET_PROFILE"
fi

# restart i3 to apply changes if i3 is running
if pgrep -x i3 >/dev/null 2>&1; then
    i3-msg reload
    i3-msg restart
    echo "i3 reloaded"
fi

echo "installation complete please logout and login again to apply all changes"