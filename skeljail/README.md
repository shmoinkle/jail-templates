# skeljail - Skeleton Jail Template

This is a skeleton wrapper. Use `launch.sh` to spin up ultra-thin jails.

In its current form, the assumtion is that these ultra-thin jails will themselves have no applications installed by default, which is why there's currently no feature in `launch.sh` to pass optional lists of packages. 

Right now it is very much single purpose script that serves me but can (and probably should) eventually be decoupled from this skeleton-skeleton so it just acts more as a general wrapper, which is to say... _bastille itself a wrapper... so this is... anyway..._

## Usage

```bash
./launch.sh -n NAME -i IP [options]
```

### Options
- `-n NAME`: Jail name (required).
- `-i IP`: Jail IP address (CIDR or 'DHCP', required).
- `-I IF`: Network interface (default: `em0`).
- `-R RELEASE`: FreeBSD release (default: `14.3-RELEASE`).
- `-T TEMPLATE`: Bastille template to apply (default: `user/skeljail`).
- `-C FILE`: File containing nullfs mount definitions.
- `-S FILE`: File containing jail configuration settings (sysctl-like).
- `-r FILE`: File containing lines to append to the jail's `/etc/rc.conf`.
- `-b`: Enable boot after creation (default is `--no-boot`).
- `-B`: Bridge mode (requires a bridge interface).
- `-D`: Enable IPv4 and IPv6.
- `-M`: Static MAC address.
- `-V`: VNET mode.
- `-F`: Force clean (destroys jail if creation/mounting fails).

---

## What it Does
- **Validates `launch.conf`**: Ensures `BASTILLE_ROOT`, `TEMPLATE`, and `RELEASE` exist as directories.
- **Validates Interface**: Checks if the interface (`-I`) exists on the host.
- **Bridge Check**: Verifies the interface is actually a bridge if `-B` is passed.
- **Network Exclusivity**: Prevents using both `-B` and `-V` at the same time.
- **Force Clean (`-F`)**: Removes jail with `bastille destroy -f` after a failed create, mount, or template.

## What it Doesn't Do
- _DOESN'T_ **Sanitize Names/IPs**: It checks that configs are present, but won't stop you from entering invalid strings (ex: symbols in names or malformed CIDR).
- _DOESN'T_ **Pre-parse Mount/Setting/RC files**: It doesn't check the contents of your `-C`, `-S` or `-r` files before running.

## Troubleshooting
Since this script does not sanitize the **Mount/Setting/RC** files, if there is a typo in a path or setting in them, the script will error when it reaches that specific command. You will have to take the appropriate action to either finalize the jail or remove it and start over (`-F` will _NOT_ trigger the removal of jails that hit these errors)

- **If a Setting fails**: Check your terminal for the error. If it's a typo, you can manually apply it by running:
  ```bash
  bastille config JAILNAME set SETTING VALUE
  ```
- **If RC Config fails**: Edit the jail's `rc.conf` under `BASTILLE_ROOT/NAME/root/etc/` directly on the host. Or use `bastille console JAILNAME` to fix the typo in `/etc/rc.conf` directly on the jail.

## Examples

### Minimum
- Running with just the name and IP (inherits all defaults from `launch.conf`):
```bash
./launch.sh -n test -i 10.0.0.40/24
```
- The resulting commands that are issued from this:
```bash
bastille create --no-boot test 14.3-RELEASE 10.0.0.40/24 em0
bastille template test user/skeljail
```

### More
- And with using all the features:
```bash
./launch.sh -bBDMFtx -n app1 -i 192.168.1.50/24 -I bridge1 \
  -C launch.example.mounts.conf \
  -S launch.example.settings.conf \
  -r launch.example.rc.conf \
  -T me/skeljail
```
- The results:
```bash
bastille create -B -M -D app1 14.3-RELEASE 192.168.1.50/24 bridge1
bastille mount app1 tmpfs tmp tmpfs rw,nosuid,mode=01777 0 0
bastille mount app1 "/usr/local/bastille/jails/mainjail/root/usr/local" "/usr/local" nullfs ro 0 0
bastille mount app1 "/home/app1" "/root" nullfs rw 0 0
bastille mount app1 "/home/app1/configs" "/etc/app1" nullfs rw 0 0
bastille mount app1 "/home/app1/music\ files" "/mnt/music" nullfs rw 0 0
bastille config app1 set priority 50
bastille config app1 set allow.mlock 1
cat launch.example.rc.conf >> /usr/local/bastille/jails/app1/root/etc/rc.conf
bastille template app1 me/skeljail
bastille restart app1
```