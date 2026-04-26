# madman
alias ls='gls --color=auto --group-directories-first'
alias ll='gls -alF --color=auto --group-directories-first'
alias cp='gcp -iv'
alias mv='gmv -iv'
alias rm='grm -iv'
alias mkdir='gmkdir -p'
alias chmod='gchmod'
alias chown='gchown'
alias ln='gln'
alias grep='ggrep --color=auto'
alias egrep='gegrep --color=auto'
alias fgrep='gfgrep --color=auto'
alias sed='gsed'
alias awk='gawk'
alias cat='gcat'
alias head='ghead'
alias tail='gtail'
alias du='gdu -h'
alias df='gdf -h'
alias date='gdate'
alias touch='gtouch'
#alias which='gwhich' # nah
alias which='type -P'
alias find='gfind'
alias xargs='gxargs'

export TERM=xterm-256color

# ensure GNU is in MANPATH
export MANPATH="/usr/local/man:$MANPATH"

# Enable Vim-style command line editing
# set -o vi # nah

# basic epoch and stuff
PS1='\n\D{%s }[\h] $? \w\n \$ '