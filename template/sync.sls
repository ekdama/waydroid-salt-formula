{% if grains['id'] == 'dom0' %}
sync:
  cmd.run:
    - name: qvm-sync-appmenus d13m-waydroid
    - order: last
add:
  cmd.run:
    - name: qvm-features d13m-waydroid default-menu-entries 'Waydroid-Sway.desktop debian-xterm.desktop'
{% endif %}
