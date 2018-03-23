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
  call dein#add('shea-parkes/lightline-gruvbox.vim', {'rev': 'shift-contrast-right'})
  call dein#add('airblade/vim-gitgutter')
  call dein#add('itchyny/lightline.vim')
  call dein#add('lifepillar/vim-mucomplete', {'on_event': 'InsertEnter'})
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('scrooloose/nerdtree', {'on_cmd': ['NERDTree', 'NERDTreeToggle']})
  call dein#add('majutsushi/tagbar', {'on_cmd': ['TagbarOpen', 'TagbarToggle']})
  call dein#add('skywind3000/asyncrun.vim')

  " Custom actions
  call dein#add('tpope/vim-surround', {'on_map': {'n': ['cs', 'ds', 'ys']}})
  call dein#add('tpope/vim-repeat', {'on_map': {'n': ['.']}})
  call dein#add('tpope/vim-commentary')
  call dein#add('Raimondi/delimitMate')
  call dein#add('b4winckler/vim-angry')
  call dein#add('kana/vim-textobj-user')
  call dein#add('bps/vim-textobj-python', { 'depends': 'vim-textobj-user', 'on_ft': ['python'] })
  call dein#add('FooSoft/vim-argwrap', {'on_cmd': ['ArgWrap']})

  " Language tools
  call dein#add('davidhalter/jedi-vim', {'on_ft': ['python']})
  call dein#add('Vimjas/vim-python-pep8-indent', {'on_ft': ['python']})  " Builtin python indentation has some quirks...
  call dein#add('pgdouyon/vim-accio', {'on_cmd': ['Accio']})

  " Git
  call dein#add('tpope/vim-fugitive')  " Not lazily loaded because it feeds statusline
  call dein#add('jreybert/vimagit', {'on_cmd': 'Magit'})
  call dein#add('idanarye/vim-merginal')  " Annoyingly misbehaves on lazy load
  " call dein#add('airblade/vim-rooter')  " Not using yet, but might go there

  call dein#end()
  call dein#save_state()
endif



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
autocmd FileType markdown,vim setlocal tabstop=2
autocmd FileType markdown,vim setlocal softtabstop=2
autocmd FileType markdown,vim setlocal shiftwidth=2

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

" Need to set these options before setting the color
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'
let g:lightline_gruvbox_style = 'hard_left'
set background=dark
colorscheme gruvbox

" Turn on some plugins as soon as neovim starts
let g:mucomplete#enable_auto_at_startup = 1
let g:indent_guides_enable_on_vim_startup = 1

" Define GGrep using FZF (inspired by fzf root readme)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   { 'dir': fnameescape(asyncrun#get_root('%')) }, <bang>0)

" Get <Esc> to actually exit FZF buffer (only needed because I overwrite the default below)
autocmd! FileType fzf tnoremap <buffer> <Esc> <c-c>

" Run pylint on save (fully async, with eventual marker updates)
autocmd! BufWritePost *.py Accio pylint %

" Fugitive uses :Make if it exists, so provide an async version
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

" Auto-open QuickFix window when something adds to it (especially AsyncRun calls)
autocmd! QuickFixCmdPost * call asyncrun#quickfix_toggle(8, 1)

" Customize ArgWrap by filetype
autocmd! FileType python let b:argwrap_tail_comma=1
autocmd! FileType vim let b:argwrap_line_prefix='\'



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
    let root = asyncrun#get_root('%')
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

function! LightlineWinnr()
  return 'w' . winnr()
endfunction

let g:lightline = {
  \ 'colorscheme': 'gruvbox',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitrepo', 'gitbranch', 'gitgutter' ],
  \             [ 'readonly', 'filename', 'modified' ]],
  \  'right': [ [ 'winnr' ],
  \             [ 'percent', 'lineinfo' ],
  \             [ 'filetype', 'fileformat', 'fileencoding' ] ]
  \ },
  \ 'inactive': {
  \   'left': [ [ 'gitrepo' ], [ 'filename' ] ],
  \  'right': [ [ 'winnr' ],
  \             [ 'filetype' ] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'fugitive#head',
  \   'gitgutter': 'GitGutterForLightLine',
  \   'gitrepo': 'GitRepoForLightLine',
  \   'fileformat': 'LightlineFileformat',
  \   'fileencoding': 'LightlineFileencoding',
  \   'winnr': 'LightlineWinnr'
  \ },
  \ }



"""""""""""""""""""""""""""
"" Custom Keybindings """""
"""""""""""""""""""""""""""

let mapleader="\<SPACE>"

" Custom basic mappings
nnoremap Y y$
nnoremap <Leader><Leader> :
nnoremap <Leader>fs :w<CR>
nnoremap <Leader>fo :AsyncRun start %<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>wq :wq<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>v "+p
nnoremap <Leader>bd :bd<CR>
nnoremap <Leader>bD :bd!<CR>
nnoremap <Leader>sc z=
nnoremap <Leader>sC z=

" Clear search results with <C-L>
nnoremap <silent> <C-L> :nohlsearch<CR><C-L>

" Allow ESC from Terminal editing
tnoremap <Esc> <C-\><C-n>G

" Stay in visual mode when indenting
vnoremap < <gv
vnoremap > >gv

" Make it a little easier to jump between splits/windows
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
nnoremap <Leader>gC :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>fu :Gblame<CR>

" Other misc plugin mappings
nnoremap <Leader>du :call dein#update()<CR>
nnoremap <Leader>t :TagbarOpen fj<CR>
nnoremap <Leader>ft :NERDTree<CR>
nnoremap <Leader>pt :NERDTree `=fnameescape(asyncrun#get_root('%'))`<CR>
nnoremap <Leader>wc :call asyncrun#quickfix_toggle(8)<CR>
nnoremap <Leader>c :call asyncrun#quickfix_toggle(8)<CR>
nnoremap <Leader>a :AsyncRun<Space>
nnoremap <Leader>A :ArgWrap<CR>
" Overwrite a mapping in mucomplete that I just can't deal with (and restore delimitMate functionality)
imap <expr> <CR> pumvisible() ? "\<C-y>" : "<Plug>delimitMateCR"



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
  sleep 210ms
  call jobsend(g:my_active_terminal_job_id, "\r")
endfunction

map <Leader>si :call LaunchIPython()<CR>
map <Leader>sr :call SendToTerminal()<CR>
