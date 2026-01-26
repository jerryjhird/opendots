#!/bin/bash

WALLPAPER_DIR="$1"
mkdir -p "$WALLPAPER_DIR"

# The symlink file to track current wallpaper
SYMLINK="$WALLPAPER_DIR/.current_wallpaper"

mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

if [ -z "$WALLPAPER_DIR" ]; then
    exit 1
fi

if [ ${#wallpapers[@]} -eq 0 ]; then
    exit 1
fi

# Determine the current wallpaper
if [ -L "$SYMLINK" ] && [ -e "$SYMLINK" ]; then
    current=$(readlink "$SYMLINK")
else
    # If symlink doesn't exist, create it pointing to the first wallpaper
    current="${wallpapers[0]}"
    ln -sf "$current" "$SYMLINK"
fi

# Find the index of the current wallpaper
index=-1
for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current" ]]; then
        index=$i
        break
    fi
done

next_index=$(( (index + 1) % ${#wallpapers[@]} ))

# Set the next wallpaper
feh --bg-scale "${wallpapers[$next_index]}"

# Update the symlink to point to the new wallpaper
ln -sf "${wallpapers[$next_index]}" "$SYMLINK"
