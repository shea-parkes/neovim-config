""""""""""""""""""""""
"" Setup Plugins """""
""""""""""""""""""""""

set runtimepath+=~\repos\vim-plugins\repos\github.com\Shougo\dein.vim

call dein#begin(expand('~\repos\vim-plugins'))
call dein#add('Shougo/dein.vim')

call dein#add('junegunn/fzf', { 'merged': 0 })  " Don't merge it because it causes conflicts with fzf.vim
call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

call dein#add('airblade/vim-gitgutter')
call dein#add('vim-airline/vim-airline')
call dein#add('nathanaelkane/vim-indent-guides')

call dein#add('tpope/vim-surround', {'on_map': {'n': ['cs', 'ds', 'ys']}})
call dein#add('tpope/vim-repeat', {'on_map': {'n': ['.']}})
call dein#add('tpope/vim-commentary')
call dein#add('Raimondi/delimitMate')
call dein#add('b4winckler/vim-angry')

call dein#add('davidhalter/jedi-vim', {'on_ft': ['python']})
call dein#add('w0rp/ale', {'on_ft': ['python']})

call dein#add('tpope/vim-fugitive')  " Not lazily loaded because it feeds airline
call dein#add('jreybert/vimagit', {'on_cmd': 'Magit'})
call dein#add('idanarye/vim-merginal')  " Annoyingly misbehaves on lazy load
" call dein#add('airblade/vim-rooter')  " Not using yet, but might go there

call dein#end()



""""""""""""""""""""""
"" Basic Options """""
""""""""""""""""""""""

colorscheme desert

set showmatch

set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4

set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.

set ignorecase          " Make searching case insensitive
set smartcase           " ... unless the query has capital letters.

" Keep from getting to the edge when scrolling
set scrolloff=2
set sidescrolloff=5

" Actually load filetype specific plugins
filetype plugin indent on

" Get spelling going
set spell spelllang=en_us

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
set autochdir
autocmd BufEnter * silent! lcd %:p:h



"""""""""""""""""""""""
"" Plugin Options """""
"""""""""""""""""""""""

let g:indent_guides_enable_on_vim_startup = 1

" Define GGrep using FZF (inspired by root readme)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep('cd ' . split(system('git rev-parse --show-toplevel'), '\n')[0] . ' && git grep --line-number '.shellescape(<q-args>), 0, <bang>0)

let g:ale_linters = {
\   'python': ['pylint'],
\}



"""""""""""""""""""""""""""
"" Custom Keybindings """""
"""""""""""""""""""""""""""

let mapleader="\<SPACE>"

" Custom basic mappings
noremap Y y$
nnoremap <Leader>fs :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>wq :wq<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>p "+p
nnoremap <Leader>bd :bd<CR>
nnoremap <Leader>bD :bd!<CR>
nnoremap <Leader>sc z=
nnoremap <Leader>sC z=

" Clear search results with <C-L>
nnoremap <silent> <C-L> :nohlsearch<CR><C-L>

" Allow ESC from Terminal editing
:tnoremap <Esc> <C-\><C-n>

" Make it a little easier to jump between splits/windows
nnoremap <Leader>j <C-W><C-J>
nnoremap <Leader>k <C-W><C-K>
nnoremap <Leader>l <C-W><C-L>
nnoremap <Leader>h <C-W><C-H>
nnoremap <Leader><Tab> :b#<CR>
nnoremap <Leader>wv <C-W>v
nnoremap <Tab> <C-W><C-W>
let i = 1
while i <= 9
    execute 'nnoremap <Leader>' . i . ' ' . i . '<C-W><C-W>'
    let i = i + 1
endwhile

" FZF mappings
nnoremap <Leader>pf :GFiles<CR>
nnoremap <Leader>pp :Files ~\repos\
nnoremap <Leader>ff :Files %:p:h
nnoremap <Leader>fr :History<CR>
nnoremap <Leader>p/ :GGrep<CR>
nnoremap <Leader>/ :Lines<CR>
nnoremap <Leader>bb :Buffers<CR>

" Git related mappings
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gm :Magit<CR>
nnoremap <Leader>gb :Merginal<CR>
nnoremap <Leader>gf :Gfetch --prune<CR>
nnoremap <Leader>gF :Gpull<CR>
nnoremap <Leader>gP :Gpush --set-upstream<CR>
nnoremap <Leader>gp :Gpush --set-upstream<Space>
nnoremap <Leader>gc :Gcommit --verbose<CR>

" Other misc plugin mappings
nnoremap <Leader>du :call dein#update()<CR>
nnoremap <Leader>ar :AirlineRefresh<CR>
noremap [e :ALEPreviousWrap<CR>
noremap ]e :ALENextWrap<CR>



"""""""""""""""""""""""""""""""""""""""""""""
"" My poor man's replacement for vim-slime ""
"""""""""""""""""""""""""""""""""""""""""""""
let g:my_active_terminal_job_id = -1

function! LaunchTerminal()
  silent exe "normal! :vsplit\n"
  silent exe "normal! :terminal\n"
  exe "normal! G\n"
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

function! SendToTerminal() range
  " Yank the last selection into register "a"
  silent exe 'normal! gv"ay'
  " Send register "a" into the terminal
  call jobsend(g:my_active_terminal_job_id, @a)
  " Pause a moment, then send a carriage return to trigger its evaluation
  sleep 100ms
  call jobsend(g:my_active_terminal_job_id, "\r")
endfunction

map <Leader>si :call LaunchIPython()<CR>
map <Leader>sr :call SendToTerminal()<CR>
