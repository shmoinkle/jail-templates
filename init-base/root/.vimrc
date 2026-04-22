" load defaults
unlet! skip_defaults_vim
source \$VIMRUNTIME/defaults.vim

" whats's your style?
syntax on             " Because we aren't cavemen
set mouse=            " Disable mouse/visual mode
set nocompatible      " Required for some features
"set number           " Line numbers (nvm)
set backspace=indent,eol,start  " Make backspace work better
set autoindent
set hlsearch          " Highlight search results
set ignorecase
set smartcase         " Case-sensitive only if you use a capital letter