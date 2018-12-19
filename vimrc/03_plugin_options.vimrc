
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
  silent exe "normal! :cclose\n"
endfunction
let g:asyncrun_exit = "call timer_start(4200, 'DelayedCloseQuickFix')"

" Customize ArgWrap by filetype
autocmd! FileType python let b:argwrap_tail_comma=1
autocmd! FileType vim let b:argwrap_line_prefix='\'

" Get Tig to open in a vertical split by default
let g:tig_open_command = 'vsplit enew'

" Detangle delimitMate and vim-closetag
au FileType html let b:delimitMate_matchpairs = "(:),[:],{:}"


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
