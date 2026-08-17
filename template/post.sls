{% if grains['id'] == 'd13m-waydroid' %}
setup:
  file.managed:
    - name: /rw/config/setup_waydroid.sh
    - source: salt://waydroid/files/setup_waydroid.sh
    - mode: '0755'
    - order: 1
/rw/config/waydroid-firstboot.sh:
  file.managed: 
    - contents: |
       #!/bin/sh
       set -eu
       export https_proxy='http://127.0.0.1:8082'
       export http_proxy='http://127.0.0.1:8082'
       sudo /rw/config/setup_waydroid.sh
       sudo https_proxy='http://127.0.0.1:8082' http_proxy='http://127.0.0.1:8082' /usr/bin/waydroid init
       rm -rf /rw/config/waydroid-firstboot.sh
    - mode: '0755'
/root/.bashrc:
  file.append:
    - order: last
    - text: |
        if [ -x /rw/config/waydroid-firstboot.sh ]; then
          /rw/config/waydroid-firstboot.sh
        fi
{% endif %}
