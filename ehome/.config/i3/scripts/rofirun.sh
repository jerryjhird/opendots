#!/usr/bin/env sh

DRUN=$(find /usr/share/applications ~/.local/share/applications \
       -name "*.desktop" 2>/dev/null | while read f; do
           grep -E '^Exec=' "$f" | head -n1 | sed -E 's/^Exec=//' | sed 's/ *%[fFuUdDnNickvm]//g'
       done)

CHOICES=$(printf "%s\n%s" "$DRUN" "" | sort -u)
SELECTED=$(echo "$CHOICES" | rofi -dmenu -i -p "run:")

if [[ -n "$SELECTED" ]]; then
    nohup $SELECTED >/dev/null 2>&1 &
fi