# FreeBSD Bastille Jail Templates

A collection of personal FreeBSD Bastille jail templates for easy jail deployment.

## init-base

Initial base template used as a foundation for other jails.
- **GNU Utilities**: Installs core GNU tools for a Linux-like shell experience.
- **Environment**: Sets Bash as the default shell with custom `.bashrc` and `.vimrc`.
- **Hardening**: Disables unnecessary services (sshd, sendmail) and hardens syslogd.
