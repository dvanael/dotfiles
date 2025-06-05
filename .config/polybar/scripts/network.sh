#!/bin/bash

# Ícones
icon_wifi="📶"
icon_eth="🌐"
icon_off="❌"

# Detecta interface conectada
interface=$(ip route | awk '/default/ {print $5}')

if [ -z "$interface" ]; then
  echo "$icon_off  Offline"
  exit 0
fi

# Checa se é Wi-Fi
if [[ "$interface" == *wl* ]]; then
  ssid=$(iwgetid -r)
  signal=$(awk '/^\s*w/ { print int($3 * 100 / 70) }' /proc/net/wireless)
  echo "$icon_wifi  $ssid ${signal}%"
else
  ip=$(ip addr show "$interface" | awk '/inet / {print $2}' | cut -d/ -f1)
  echo "$icon_eth  $interface ($ip)"
fi

