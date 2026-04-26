# init-base - Initial Base Template

This makes my initial base jail. Just a skeleton with a few common settings and applications I need. Any services I install here I intend to launch in other jails by mounting this jails /usr/local in that jail.

## Highlights

Since this is a base jail I just install all the tools and tweaks I'd like to have accessible in each of the subsequent jails.

- **Bash Shell**: Sets Bash as the default shell for root.
- **Vim Configuration**: Adds a `.vimrc` with some tweaks, including disabling **_MOUSE_**
- **System Defaults**:
  - Disables `sshd` and `sendmail`.
  - Enables `clear_tmp` on startup.
  - Configures `syslogd` to prevent network listening.
- **Locale Support**: Sets default locale because I only speak one language :(
- **Persistence**: Mounts a different `/root` directory (to bring up a new "base" jail easily)

## Included Packages

- All the important stuff I need, inlcuding critcal programs such as `fastfetch` and `chafa` 👀
```bash
export ASSUME_ALWAYS_YES=yes && pkg bash bash-completion htop ncdu vim curl wget jq screen python313 git-tiny rsync tree fastfetch chafa
```