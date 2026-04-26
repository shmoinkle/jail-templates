export TERM=xterm-256color

# ensure GNU is in MANPATH
export MANPATH="/usr/local/man:$MANPATH"

# basic epoch and stuff
PS1='\n\D{%s }[\h] $? \w\n \$ '