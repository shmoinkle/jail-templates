# init-base - Initial Base Template

This makes an initial base jail that can be cloned, etc, to make other jails later. It's personalized to my liking :)

## Features

- **GNU Utilities**: Installs GNU tools (`coreutils`, `gsed`, `ggrep`, `gawk`, etc.) so you can LARP as if it was Linux.
- **Bash Shell**: Sets Bash as the default shell for root, because Linux lol.
- **Vim Configuration**: Adds a `.vimrc` with some tweaks, including disabling **_MOUSE_**
- **System Defaults**:
  - Disables `sshd` and `sendmail`.
  - Enables `clear_tmp` on startup.
  - Configures `syslogd` to prevent network listening.
- **Locale Support**: Sets default locale because I only speak one language :(
- **Persistence**: Mounts a directory in my filesystem as the jail's `/root` directory.

## Included Packages

- All the important stuff I need, inlcuding critcal programs such as `fastfetch` and `chafa`
```bash
export ASSUME_ALWAYS_YES=yes && pkg bash bash-completion htop ncdu vim coreutils gnugrep gsed gawk findutils curl wget jq screen python313 git-tiny rsync tree fastfetch chafa
```

## Usage

- If after reading above you still want this template:
```bash
BASTILLE_ROOT=/usr/local/bastille # or whatever it is for you
git clone https://github.com/shmoinkle/jail-templates "${BASTILLE_ROOT}/templates/shmoinkle"
# don't forget to update it so the paths are yours
bastille template JAILNAME shmoinkle/init-base
```
