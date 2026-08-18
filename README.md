# Waydroid Salt Formula

Waydroid Salt Formula to install a Waydroid emulator in QubesOS, inside a TemplateVM and an usable AppVM.
Upon template creation, launch of the template as root user is required. Meanwhile it is not a strict requirement, since the setup should not in normal circumstances ask for any standard input, it is advised to boot the template.

## Usage

```
sudo cp -a waydroid/ /srv/salt/
sudo qubesctl states.apply waydroid.template
sudo qubesctl --skip-dom0 --templates=d13m-waydroid waydroid.template
qvm-run --pass-io -u root d13m-waydroid
sudo qubesctl states.apply waydroid.qvm
```

## License

The following software is provided through the MIT license.
