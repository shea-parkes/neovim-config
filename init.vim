""""""""""""""""""""""
"" Setup Plugins """""
""""""""""""""""""""""

set runtimepath+=~\repos\vim-plugins\repos\github.com\Shougo\dein.vim

if dein#load_state(expand('~\repos\vim-plugins'))
  call dein#begin(expand('~\repos\vim-plugins'))
  call dein#add('Shougo/dein.vim')

  " Fuzzy finding
  call dein#add('junegunn/fzf', { 'merged': 0 })  " Don't merge it because it causes conflicts with fzf.vim
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })

  " UI/UX
  call dein#add('morhetz/gruvbox')
  call dein#add('shinchu/lightline-gruvbox.vim')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('itchyny/lightline.vim')
  call dein#add('lifepillar/vim-mucomplete', {'on_event': 'InsertEnter'})
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('scrooloose/nerdtree', {'on_cmd': ['NERDTree', 'NERDTreeToggle']})
  call dein#add('majutsushi/tagbar', {'on_cmd': ['TagbarOpen', 'TagbarToggle']})
  call dein#add('skywind3000/asyncrun.vim', {'on_cmd': ['AsyncRun']})

  " Custom actions
  call dein#add('tpope/vim-surround', {'on_map': {'n': ['cs', 'ds', 'ys']}})
  call dein#add('tpope/vim-repeat', {'on_map': {'n': ['.']}})
  call dein#add('tpope/vim-commentary')
  call dein#add('Raimondi/delimitMate')
  call dein#add('b4winckler/vim-angry')
  call dein#add('kana/vim-textobj-user')
  call dein#add('bps/vim-textobj-python', { 'depends': 'vim-textobj-user', 'on_ft': ['python'] })

  " Language tools
  call dein#add('davidhalter/jedi-vim', {'on_ft': ['python']})
  call dein#add('pgdouyon/vim-accio', {'on_cmd': ['Accio']})

  " Git
  call dein#add('tpope/vim-fugitive')  " Not lazily loaded because it feeds airline
  call dein#add('jreybert/vimagit', {'on_cmd': 'Magit'})
  call dein#add('idanarye/vim-merginal')  " Annoyingly misbehaves on lazy load
  " call dein#add('airblade/vim-rooter')  " Not using yet, but might go there

  call dein#end()
  call dein#save_state()
endif



""""""""""""""""""""""
"" Basic Options """""
""""""""""""""""""""""

set background=dark
colorscheme gruvbox

set nowrap

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
"   The second method is stickier, but some plugins check for `autochdir`...
set autochdir
autocmd BufEnter * silent! lcd %:p:h

" Setup completion to play well with being auto-triggered
set completeopt+=menuone
set completeopt+=noinsert



"""""""""""""""""""""""
"" Plugin Options """""
"""""""""""""""""""""""

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'

let g:mucomplete#enable_auto_at_startup = 1

let g:indent_guides_enable_on_vim_startup = 1

function! FindProjectRoot()
  " Return root of git project (taken from fzf's GFiles)
  try
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    return v:shell_error ? '' : root
  catch
    return ''
  endtry
endfunction

" Define GGrep using FZF (inspired by fzf root readme)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep('cd ' . FindProjectRoot() . ' && git grep --line-number '.shellescape(<q-args>), 0, <bang>0)

" Get <Esc> to actually exit FZF buffer (only needed because I overwrite the default below)
autocmd! FileType fzf tnoremap <buffer> <Esc> <c-c>

function! NERDTreeInProject()
  execute ':NERDTree' FindProjectRoot()
endfunction

" Run pylint on save (fully async, with eventual marker updates)
autocmd BufWritePost *.py Accio pylint %

" Fugitive uses :Make if it exists, so provide an async version
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>



"""""""""""""""""""""""""
"" Lightline Config """""
"""""""""""""""""""""""""

function! GitGutterForLightLine()
  let deltas = GitGutterGetHunkSummary()
  if winwidth(0) < 120
      return ''
  elseif deltas[0] == 0 && deltas[1] == 0 && deltas[2] == 0
    return ''
  else
    return '+' . deltas[0] . ' ~' . deltas[1] . ' -' . deltas[2]
  endif
endfunction

function! GitRepoForLightLine()
  " Need to cache for each buffer for performance
  if !exists('b:my_git_repo_folder_name')
    let root = FindProjectRoot()
    let b:my_git_repo_folder_name = root != '' ? fnamemodify(root, ':t') : 'None'
  endif
  if winwidth(0) < 100
      return ''
  else
    return b:my_git_repo_folder_name != 'None' ? b:my_git_repo_folder_name : ''
  endif
endfunction

function! LightlineFileformat()
  return winwidth(0) > 120 ? &fileformat : ''
endfunction

function! LightlineFileencoding()
  if winwidth(0) < 120
    return ''
  else
    return $fileencoding !=# '' ? &fileencoding : &encoding
  endif
endfunction

let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitrepo', 'gitbranch', 'gitgutter'],
      \             ['readonly', 'filename', 'modified' ]],
      \  'right': [ [ 'winnr' ],
      \             [ 'percent', 'lineinfo' ],
      \             [ 'filetype', 'fileformat', 'fileencoding' ] ]
      \ },
      \ 'inactive': {
            \ 'left': [ [ 'gitrepo' ], [ 'filename' ] ],
            \ 'right': [ [ 'winnr' ],
            \            [ 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \   'gitgutter': 'GitGutterForLightLine',
      \   'gitrepo': 'GitRepoForLightLine',
      \   'fileformat': 'LightlineFileformat',
      \   'fileencoding': 'LightlineFileencoding'
      \ },
      \ }



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
tnoremap <Esc> <C-\><C-n>G

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
nnoremap <Leader>pp :Files ~\repos\
nnoremap <Leader>pf :GFiles<CR>
nnoremap <Leader>p/ :GGrep<CR>
nnoremap <Leader>ff :Files %:p:h
nnoremap <Leader>fr :History<CR>
nnoremap <Leader>bb :Buffers<CR>
nnoremap <Leader>/ :BLines<CR>

" Git related mappings
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gm :Magit<CR>
nnoremap <Leader>gb :Merginal<CR>
nnoremap <Leader>gf :Gfetch --prune<CR>
nnoremap <Leader>gF :Gpull<CR>
nnoremap <Leader>gP :Gpush --set-upstream<CR>
nnoremap <Leader>gp :Gpush --set-upstream<Space>
nnoremap <Leader>gc :Gcommit --verbose<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>fu :Gblame<CR>

" Other misc plugin mappings
nnoremap <Leader>du :call dein#update()<CR>
noremap <Leader>t :TagbarOpen fj<CR>
noremap <Leader>ft :NERDTree<CR>
map <Leader>pt :call NERDTreeInProject()<CR>
" Overwrite a mapping in mucomplete that I just can't deal with
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"



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
