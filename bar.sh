#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color
mode="default"
if [ $# -gt 0 ]; then
    mode=$1
fi
if [ $mode = "-h" ]; then
    echo "Usage: $0 [mode]"
    echo "  modes: affogato-homedock affogato-workdock affogato-laptop"
    echo "         ramirez-homedock ramirez-workdock ramirez-laptop"
    exit 1
fi

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/tundra

volume() {
    DEFSINK=$(pactl get-default-sink)
    MUTED=false
    if pactl get-sink-mute $DEFSINK | grep -q yes
    then
        MUTED=true
    else
        MUTED=false
        VOL=$(pactl get-sink-volume $DEFSINK | awk '{print $5}')
    fi
}

cpu() {
  #cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
  cpu_val=$(awk '{print $1" "$2" "$3}' /proc/loadavg)

  printf "^c$black^ ^b$green^ CPU"
  printf "^c$white^ ^b$grey^ $cpu_val ^b$black^"
}

pkg_updates() {
  #updates=$({ timeout 20 doas xbps-install -un 2>/dev/null || true; } | wc -l) # void
  updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch
  # updates=$({ timeout 20 aptitude search '~U' 2>/dev/null || true; } | wc -l)  # apt (ubuntu, debian etc)

  if [ -z "$updates" ]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$white^    $updates"" updates"
  fi
}

battery() {
  #val="$(cat /sys/class/power_supply/BAT0/capacity)"
  val=$(acpi | awk -F: '{print $2":"$3":"$4}' | sed 's/%/%%/')
  printf "^c$black^ ^b$red^ BAT"
  printf "^c$white^ ^b$grey^ $val ^b$black^"

}

brightness() {
  printf "^c$red^   "
  printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$red^^b$black^  "
  printf "^c$red^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

lan() {
    iface=$1
	case "$(cat /sys/class/net/$iface/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected ($iface)" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected ($iface)" ;;
	esac
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
    date_string=$(date +"%a %b %e %Y %H:%M:%S %z")
	printf "^c$black^ ^b$darkblue^ 󱑆 "
	printf "^c$black^^b$blue^ $date_string  "
}

while true; do

    [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
    interval=$((interval + 1))

    if [ $mode = "affogato-laptop" ]; then
        sleep 1 && xsetroot -name "$(cpu) $(battery) $(mem) $(wlan) $(clock)"
    elif [ $mode = "affogato-workdock" ]; then
        sleep 1 && xsetroot -name "$(cpu) $(battery) $(mem) $(wlan) $(clock)"
    elif [ $mode = "affogato-homedock" ]; then
        sleep 1 && xsetroot -name "$(cpu) $(mem) $(lan enp0s13f0u2u4) $(clock)"
    elif [ $mode = "ramirez-laptop" ]; then
        sleep 1 && xsetroot -name "$(cpu) $(battery) $(mem) $(wlan) $(clock)"
    elif [ $mode = "ramirez-workdock" ]; then
        sleep 1 && xsetroot -name "$(cpu) $(battery) $(mem) $(wlan) $(clock)"
    elif [ $mode = "ramirez-homedock" ]; then
        sleep 1 && xsetroot -name "$(cpu) $(battery) $(mem) $(wlan) $(clock)"
    else
        sleep 1 && xsetroot -name "$(cpu) $(battery) $(mem) $(wlan) $(clock)"
    fi

done
