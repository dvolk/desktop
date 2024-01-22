set -x
set -e
nmcli d wifi hotspot ifname wlp4s0 ssid "${WIFI_SSID}" password "${WIFI_PASSWORD}"
sleep 2
nmcli con modify Hotspot 802-11-wireless-security.key-mgmt wpa-psk
nmcli con modify Hotspot 802-11-wireless-security.proto rsn
nmcli con modify Hotspot 802-11-wireless-security.pairwise ccmp
nmcli con modify Hotspot 802-11-wireless-security.group ccmp
nmcli con modify Hotspot 802-11-wireless.band bg

