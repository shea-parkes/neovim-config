""""""""""""""""""""""
"" Setup Plugins """""
""""""""""""""""""""""
" All plugins now managed by git submodules + pathogen
execute 'source ' . expand('<sfile>:p:h') . '/bundle/vim-pathogen/autoload/pathogen.vim'
execute pathogen#infect()



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

function! TrimTrailingLines()
  let lastLine = line('$')
  let lastNonblankLine = prevnonblank(lastLine)
  if lastLine > 0 && lastNonblankLine != lastLine
    echom 'Deleting extra newlines at end of file'
    execute lastNonblankLine + 1 . ',$delete _'
  endif
endfunction

autocmd BufWritePre * call TrimTrailingLines()

" Treeview for netrw
let g:netrw_liststyle = 3



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

" A quick function to find the root of a git repo
function! GetGitRoot()
  let dot_git_path = finddir('.git', '.;')
  if dot_git_path == ''
    return ''
  else
    return fnameescape(fnamemodify(dot_git_path, ':h'))
  endif
endfunction


"""""""""""""""""""""""
"" Plugin Options """""
"""""""""""""""""""""""

" Need to set these options before setting the color
set background=dark
colorscheme gruvbox

" Define GGrep using FZF (inspired by fzf root readme)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({ 'dir': GetGitRoot() }), <bang>0)

" Get <Esc> to actually exit FZF buffer (only needed because I overwrite the default below)
autocmd! FileType fzf tnoremap <buffer> <Esc> <c-c>

" Configure Neomake
call neomake#configure#automake('rwn', 2100)
let g:neomake_python_enabled_makers = ['pylint']

" Jedi just isn't fast enough with numpy/pandas/etc
let g:jedi#popup_on_dot = 0

" Let Black know we'll bring our own executable
let g:black_use_virtualenv = 0

" Customize ArgWrap by filetype
autocmd! FileType python let b:argwrap_tail_comma=1
autocmd! FileType vim let b:argwrap_line_prefix='\'

" Setup Python auto-formatting
autocmd BufWritePre *.py execute ':Black'
autocmd BufWritePost *.py silent !reorder-python-imports %



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
    let root = GetGitRoot()
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
  \             [ 'gitrepo', 'gitgutter' ],
  \             [ 'readonly', 'filename', 'modified' ]],
  \  'right': [ 
  \             [ 'percent', 'lineinfo' ],
  \             [ 'filetype', 'fileformat', 'fileencoding' ] ]
  \ },
  \ 'inactive': {
  \   'left': [ [ 'gitrepo' ], [ 'filename' ] ],
  \  'right': [ 
  \             [ 'filetype' ] ]
  \ },
  \ 'component_function': {
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
nnoremap Y y$
nnoremap <Leader><Leader> :
nnoremap <Leader>fs :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>wq :wq<CR>
nnoremap <Leader>e :e<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>y "+yy
vnoremap <Leader>y "+y
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
nnoremap <silent> <Leader>+ :exe "vertical resize " . (winwidth(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "vertical resize " . (winwidth(0) * 2/3)<CR>

" FZF mappings
nnoremap <Leader>pp :Files ~\repos\
nnoremap <Leader>pf :GFiles<CR>
nnoremap <Leader>p/ :GGrep<CR>
nnoremap <Leader>ff :Files %:p:h
nnoremap <Leader>fr :History<CR>
nnoremap <Leader>bb :Buffers<CR>
nnoremap <Leader>/ :BLines<CR>

" Other misc plugin mappings
nnoremap <Leader>ft :Explore<CR>
nnoremap <Leader>pt :edit `=GetGitRoot()`<CR>
nnoremap <Leader>a :ArgWrap<CR>
nnoremap <Leader>b :Black<CR>
nnoremap <Leader>c :copen<CR>
nnoremap <Leader>C :cclose<CR>
nnoremap <Leader>l :lopen<CR>
nnoremap <Leader>L :lclose<CR>

" Notes for NetRW
" `-` - Vim-Vinegar overloaded 'go up'
" `gh` - toggle hidden files
" `%` - Create a new file
" `d` - Create a new directory
" `R` - Rename file
" `D` - Delete file/folder
" Then the gauntlet for copy/move:
"   `mt` - Mark the target directory
"   `mf` - Mark a file or directory
"   `mc` - Copy all the marked files/directories to the target directory
"   `mm` - Move all the marked files/directories to the target directory

" Make completions work the way you'd think they work
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" cohama/lexima.vim is already making <CR> play ~nice with pumvisible()
