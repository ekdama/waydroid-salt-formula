{% if grains['id'] == 'd13m-waydroid' %}

packages:
  pkg.installed:
    - pkgs:
      - 'linux-image-amd64'
      - 'linux-headers-amd64'
      - 'grub2'
      - 'qubes-kernel-vm-support'
{% endif %}
