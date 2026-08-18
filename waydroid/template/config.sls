config:
 qvm.present:
  - name: 'd13m-waydroid'
  - label: 'red'
  - mem: 4000
  - vcpus: 4
  - class: 'TemplateVM'
config-prefs:
 qvm.prefs:
  - kernel: 'pvgrub2-pvh'
  - order: 2
config-clone:
 cmd.run:
  - name: 'qvm-clone debian-13-minimal d13m-waydroid'
  - order: 1
