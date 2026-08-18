#!/bin/bash
apt install -y ca-certificates extrepo
https_proxy=http://127.0.0.1:8082 http_proxy=http://127.0.0.1:8082 extrepo enable waydroid
apt update
apt install -y sway qubes-core-agent-networking waydroid pipewire-qubes curl unzip build-essential libx11-dev libxtst-dev xclip wl-clipboard pip python3-venv x11-utils thunar qubes-core-agent-thunar
mkdir -p /etc/systemd/system/waydroid-container.service.d
cat << 'EOF' | tee /etc/systemd/system/waydroid-container.service.d/override.conf >/dev/null
[Unit]
ConditionPathExists=!/run/qubes/this-is-templatevm
EOF
curl --proxy http://127.0.0.1:8082/ --tlsv1.2 --proto =https --max-time 180 https://codeload.github.com/cdown/clipnotify/zip/refs/heads/master -o clipnotify-master.zip
unzip -j clipnotify-master.zip -d clipnotify
cd clipnotify
mkdir -p /opt/bin
sed -i "s|/usr/local|/opt|g" Makefile
make
make install
echo 'export PATH="/opt/bin:$PATH"' >> /etc/profile.d/opt-bin.sh
echo "exec /opt/bin/x11-wl-clip.sh" > /etc/sway/config.d/99-x11-wl-clip.conf
mkdir -p /opt/bin
cat << 'EOF' | tee /opt/bin/x11-wl-clip.sh >/dev/null
#!/bin/bash
x11_wl='while DISPLAY=":0" clipnotify -s clipboard; do xclip -d ":0" -selection clipboard -o | wl-copy; done'
wl_x11='wl-paste -nw xclip -d ":0" -selection clipboard'
eval "${x11_wl}" &>/dev/null &
eval "${wl_x11}" &>/dev/null
pstree -A -p $$ | grep -Eow "[0-9]+" | xargs kill &>/dev/null
EOF
chmod +x /opt/bin/x11-wl-clip.sh
python3 -m venv /opt/venv/pyclip
source /opt/venv/pyclip/bin/activate
pip install --proxy http://127.0.0.1:8082 pyclip
deactivate
echo 'export PATH="$PATH:/opt/venv/pyclip/bin"' >> /etc/profile.d/python-venv.sh
echo 'export PYTHONPATH="$PYTHONPATH:/opt/venv/pyclip/lib/python3.11/site-packages"' >> /etc/profile.d/python-venv.sh
cat << 'EOF' | tee /etc/systemd/system/waydroid-firewall.service >/dev/null
[Unit]
ConditionPathExists=!/run/qubes/this-is-templatevm
PartOf=waydroid-container.service
After=waydroid-container.service
BindsTo=waydroid-container.service
Requires=qubes-iptables.service
After=qubes-iptables.service
BindsTo=qubes-iptables.service
[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c "if (nft create chain ip qubes waydroid-input) &>/dev/null; then nft add rule ip qubes custom-input jump waydroid-input; fi"
ExecStart=/usr/bin/bash -c "if (nft create chain ip qubes waydroid-forward) &>/dev/null; then nft add rule ip qubes custom-forward jump waydroid-forward; fi"
ExecStart=/usr/sbin/nft add rule ip qubes waydroid-input iifname "waydroid0" meta l4proto {tcp, udp} th dport { 53, 67 } accept
ExecStart=/usr/sbin/nft add rule ip qubes waydroid-forward iifname "waydroid0" oifgroup 1 accept
ExecStart=/usr/sbin/nft add rule ip qubes waydroid-forward oifname "waydroid0" iifgroup 1 accept
ExecStop=/usr/sbin/nft flush chain ip qubes waydroid-input
ExecStop=/usr/sbin/nft flush chain ip qubes waydroid-forward
RemainAfterExit=yes
[Install]
WantedBy=waydroid-container.service
EOF
systemctl daemon-reload
systemctl enable waydroid-firewall.service
echo "default_border none" > /etc/sway/config.d/94-disable-window-titlebar.conf
perl -0777 -i -pe 's/(^\h*bar\s*|\v\h*bar\s*)(\{(?:(?>[^{}]+)|(?-1))*\})//g' /etc/sway/config
cat << 'EOF' | tee /opt/bin/sway-waydroid.sh >/dev/null
#!/bin/bash
sway &>/dev/null &
WAYLAND_DISPLAY="wayland-1" XDG_SESSION_TYPE="wayland" DISPLAY=":1" waydroid first-launch &>/dev/null &
for i in $(seq 1 3);
do
    if xwininfo -name "wlroots - X11-1" &>/dev/null; then
        break
    fi
    sleep 1
done
while xwininfo -name "wlroots - X11-1" &>/dev/null; do
    sleep 2
done
WAYLAND_DISPLAY="wayland-1" XDG_SESSION_TYPE="wayland" DISPLAY=":1" waydroid session stop &>/dev/null
pstree -A -p $$ | grep -Eow "[0-9]+" | xargs kill &>/dev/null
EOF
chmod +x /opt/bin/sway-waydroid.sh
cat << 'EOF' | tee /usr/share/applications/Waydroid-Sway.desktop >/dev/null
[Desktop Entry]
Type=Application
Name=Waydroid-Sway
Exec=/opt/bin/sway-waydroid.sh
Icon=waydroid
Categories=X-WayDroid-App;
X-Purism-FormFactor=Workstation;Mobile;
EOF
cat << 'EOF' | tee /opt/bin/waydroid-install-apk >/dev/null
#!/bin/sh
WAYLAND_DISPLAY="wayland-1" XDG_SESSION_TYPE="wayland" DISPLAY=":1" waydroid app install $1
EOF
chmod +x /opt/bin/waydroid-install-apk
cat << 'EOF' | tee /opt/bin/waydroid-upgrade >/dev/null
#!/bin/sh
https_proxy=http://127.0.0.1:8082 http_proxy=http://127.0.0.1:8082 waydroid upgrade
EOF
chmod +x /opt/bin/waydroid-upgrade
