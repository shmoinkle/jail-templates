# FreeBSD Bastille Jail Templates

A collection of personal FreeBSD Bastille jail templates and automation scripts for streamlining the creation of manageable application environments.

## init-base

Initial base template used as a foundation for other jails.
- **GNU Utilities**: Installs core GNU tools for a Linux-like shell experience.
- **Environment**: Sets Bash as the default shell with custom `.bashrc` and `.vimrc`.
- **Hardening**: Disables unnecessary services (sshd, sendmail) and hardens syslogd.

## skeljail

A "skeleton of a skeleton" template (currently) designed to make ultra-thin jails that borrow applications from other mounts.

### Automation: launch.sh
`launch.sh` is a robust wrapper that handles (some) validation, creation, mounting, and template application in one go.

#### Options
- `-n NAME`: Jail name (required).
- `-i IP`: Jail IP address or 'DHCP' (required).
- `-I IF`: Network interface (default from `launch.conf`).
- `-R RELEASE`: FreeBSD release (default from `launch.conf`).
- `-T TEMPLATE`: Template to apply (default from `launch.conf`).
- `-C FILE`: `nullfs` mount definitions.
- `-S FILE`: Jail configuration settings (`bastille config set`).
- `-r FILE`: Lines to append to the jail's `/etc/rc.conf`.
- `-b`: Enable boot (removes `--no-boot`).
- `-B`: Bridge mode (validates `IF` is a bridge).
- `-D`: Enable dual-stack IPv4/v6.
- `-M`: Static MAC address.
- `-V`: VNET mode.
- `-F`: Force clean (destroys jail on critical failure).
- `-t`: Create a `tmpfs` at `/tmp`.
- `-x`: Restart jail after configuration is complete.

#### Example
```bash
./skeljail/launch.sh -B -D -M -b -F -t -x \
  -n app1 -i 192.168.1.3/24 -I bridge0 \
  -C app_mounts.txt -S app_settings.txt -r app_rc.conf
```