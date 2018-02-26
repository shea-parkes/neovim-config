set runtimepath+=~\repos\vim-plugins\repos\github.com\Shougo\dein.vim

call dein#begin(expand('~\repos\vim-plugins'))
call dein#add('Shougo/dein.vim')
call dein#add('junegunn/fzf', { 'merged': 0 })  " Don't merge it because it causes conflicts with fzf.vim
call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
call dein#add('tpope/vim-surround')
call dein#add('tpope/vim-repeat')
call dein#add('tpope/vim-fugitive')
call dein#add('airblade/vim-gitgutter')
call dein#add('Raimondi/delimitMate')
call dein#end()

" Update view faster, mostly for git-gutter
set updatetime=2100

" Keep from getting to the edge when scrolling
set scrolloff=2
set sidescrolloff=5

" Stop auto-killing "hidden" buffers (important for terminals)
set hidden

" Allow ESC from Terminal editing
:tnoremap <Esc> <C-\><C-n>

" Actually load filetype specific plugins
filetype plugin indent on

" Have CWD follow the current window (nice for FZF and others)
set autochdir

colorscheme desert

set showmatch
set expandtab
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.

set ignorecase          " Make searching case insensitive
set smartcase           " ... unless the query has capital letters.

let mapleader="\<SPACE>"
nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
noremap Y y$

" Make it a little easier to jump between splits/windows
nnoremap <Leader>j <C-W><C-J>
nnoremap <Leader>k <C-W><C-K>
nnoremap <Leader>l <C-W><C-L>
nnoremap <Leader>h <C-W><C-H>

" Integrate some leader fun
nnoremap <Leader>pf :GFiles<CR>
nnoremap <Leader>ff :Files ~\repos\
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gf :Gfetch<CR>
nnoremap <Leader>gF :Gpull<CR>
nnoremap <Leader>gP :Gpush<CR>
nnoremap <Leader>fs :w<CR>
nnoremap <Leader>q :q<CR>

" My poor man's replacement for vim-slime
let g:my_active_terminal_job_id = -1

function! LaunchTerminal()
  silent exe "normal! :terminal\n"
  call SetActiveTerminalJobID()
endfunction

function! LaunchIPython()
  call LaunchTerminal()
  call jobsend(g:my_active_terminal_job_id, "ipython\r")
endfunction

function! SetActiveTerminalJobID()
  let g:my_active_terminal_job_id = b:terminal_job_id
  echom "Active terminal job ID set to " . g:my_active_terminal_job_id
endfunction

function! SendToTerminal()

  " Yank the last selection into register "a"
  silent exe 'normal! gv"ay'

  " Send register "a" into the terminal
  call jobsend(g:my_active_terminal_job_id, @a)

  " Pause a moment, then send a carraige return to trigger its evaluation
  sleep 100ms
  call jobsend(g:my_active_terminal_job_id, "\r")

endfunction

map <Leader>si :call LaunchIPython()<CR>
map <Leader>sr :call SendToTerminal()<CR>

