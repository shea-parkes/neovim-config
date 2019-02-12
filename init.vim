""""""""""""""""""""""
"" Setup Plugins """""
""""""""""""""""""""""
" All plugins now managed by git submodules + pathogen
source ~/nvim/bundle/vim-pathogen/autoload/pathogen.vim
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



"""""""""""""""""""""""
"" Plugin Options """""
"""""""""""""""""""""""

" Need to set these options before setting the color
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'
let g:lightline_gruvbox_style = 'hard_left'
set background=dark
colorscheme gruvbox

" Turn on/off some plugins as soon as neovim starts
let g:jedi#popup_on_dot = 0
let g:indent_guides_enable_on_vim_startup = 1

" Define GGrep using FZF (inspired by fzf root readme)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   { 'dir': fnameescape(asyncrun#get_root('%')) }, <bang>0)

" Get <Esc> to actually exit FZF buffer (only needed because I overwrite the default below)
autocmd! FileType fzf tnoremap <buffer> <Esc> <c-c>

" Run linters on save (fully async, with eventual marker updates)
autocmd! BufWritePost *.py Accio pylint %
autocmd! BufWritePost *.js Accio eslint %

" Fugitive uses :Make if it exists, so provide an async version
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

" Auto-open QuickFix window when something adds to it (especially AsyncRun calls)
autocmd! QuickFixCmdPost * call asyncrun#quickfix_toggle(8, 1)

" Auto-close QuickFix a little while after AsyncRun finishes
function! DelayedCloseQuickFix(timer)
  silent! execute "normal! :cclose\n"
endfunction
let g:asyncrun_exit = "call timer_start(4200, 'DelayedCloseQuickFix')"

" Customize ArgWrap by filetype
autocmd! FileType python let b:argwrap_tail_comma=1
autocmd! FileType vim let b:argwrap_line_prefix='\'

" Get Tig to open in a vertical split by default
let g:tig_open_command = 'vsplit enew'

" Detangle illuminate and semshi
let g:Illuminate_ftblacklist = ['python']



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
nnoremap <Leader>ww :w!<CR>
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
let i = 1
while i <= 9
  execute 'nnoremap <Leader>' . i . ' ' . i . '<C-W><C-W>'
  let i = i + 1
endwhile
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

" Git related mappings
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gm :Merginal<CR>
nnoremap <Leader>gb :Merginal<CR>
nnoremap <Leader>gt :Tig<CR>
nnoremap <Leader>gT :AsyncRun start tig<CR>
nnoremap <Leader>gf :Gfetch --prune<CR>
nnoremap <Leader>gF :Gpull<CR>
nnoremap <Leader>gP :Gpush --set-upstream<CR>
nnoremap <Leader>gp :Gpush --set-upstream<Space>
nnoremap <Leader>gc :Gcommit --verbose<CR>
nnoremap <Leader>gC :Gcommit<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>fu :Gblame<CR>

" Other misc plugin mappings
nnoremap <Leader>t :TagbarOpen fj<CR>
nnoremap <Leader>ft :NERDTreeToggle<CR>
nnoremap <Leader>pt :NERDTreeToggle `=fnameescape(asyncrun#get_root('%'))`<CR>
nnoremap <Leader>wc :call asyncrun#quickfix_toggle(8)<CR>
nnoremap <Leader>c :call asyncrun#quickfix_toggle(8)<CR>
nnoremap <Leader>a :AsyncRun<Space>
nnoremap <Leader>A :ArgWrap<CR>

" Make completions work the way you'd think they work
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" cohama/lexima.vim is already making <CR> play ~nice with pumvisible()



"""""""""""""""""""""""""""""""""""""""""""""
"" My poor man's replacement for vim-slime ""
"""""""""""""""""""""""""""""""""""""""""""""
let g:my_active_terminal_job_id = -1

function! LaunchTerminal() range
  silent exe "normal! :vsplit\n"
  silent exe "normal! :terminal\n"
  exe "normal! G\n"
  call SetActiveTerminalJobID()
endfunction

function! LaunchIPython() range
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

function! SendNudgeToTerminal() range
  " Send in a nudge.  Can help trigger IPython evaluation
  call jobsend(g:my_active_terminal_job_id, "\r")
endfunction

map <Leader>si :call LaunchIPython()<CR>
map <Leader>sr :call SendToTerminal()<CR>
map <Leader>ss :call SendNudgeToTerminal()<CR>
