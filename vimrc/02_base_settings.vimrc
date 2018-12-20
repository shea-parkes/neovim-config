
""""""""""""""""""""""
"" Basic Options """""
""""""""""""""""""""""

" Actually load filetype specific plugins
filetype plugin indent on

" Get spelling going
set spell spelllang=en_us

" Search smarter
set ignorecase
set smartcase

" Show matching ~brackets
set showmatch

" Split like you'd expect in other programs
set splitbelow
set splitright

" Keep from getting to the edge when scrolling
set scrolloff=2
set sidescrolloff=5

" Only wrap when you're likely writing prose
set nowrap
autocmd FileType markdown setlocal wrap

" Manhandle tabs
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
autocmd FileType markdown,vim,html,javascript setlocal tabstop=2
autocmd FileType markdown,vim,html,javascript setlocal softtabstop=2
autocmd FileType markdown,vim,html,javascript setlocal shiftwidth=2

" Show whitespace
set listchars=tab:→\ ,trail:·,extends:↷,precedes:↶
set list

" Delete trailing whitespace
autocmd BufWritePre * %s/\s\+$//e

function TrimTrailingLines()
  let lastLine = line('$')
  let lastNonblankLine = prevnonblank(lastLine)
  if lastLine > 0 && lastNonblankLine != lastLine
    echom 'Deleting extra newlines at end of file'
    execute lastNonblankLine + 1 . ',$delete _'
  endif
endfunction

autocmd BufWritePre * call TrimTrailingLines()


""""""""""""""""""""""""""""""""""""""""""""
"" Builtin Options that influence plugins ""
""""""""""""""""""""""""""""""""""""""""""""

" Update view faster, mostly for git-gutter
set updatetime=100

" Stop auto-killing "hidden" buffers (important for terminals)
set hidden

" Have CWD follow the current window (nice for FZF and others)
"   The second method is stickier, but some plugins check for `autochdir`...
set autochdir
autocmd BufEnter * silent! lcd %:p:h
