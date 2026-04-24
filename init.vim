" All plugins now managed by git submodules + native packages


""""""""""""""""""""""
"" Basic Options """""
""""""""""""""""""""""


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

" Treeview for netrw
let g:netrw_liststyle = 3



""""""""""""""""""""""""""""""""""""""""""""
"" Builtin Options that influence plugins ""
""""""""""""""""""""""""""""""""""""""""""""

" Update view faster, mostly for git-gutter
set updatetime=100

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
set termguicolors
colorscheme gruvbox-baby

" Define GGrep using FZF (inspired by fzf root readme)
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({ 'dir': GetGitRoot() }), <bang>0)

" Detangle fzf split action from clipboard
let g:fzf_action = { 'ctrl-w': 'vsplit' }

" Get <Esc> to actually exit FZF buffer (only needed because I overwrite the default below)
autocmd! FileType fzf tnoremap <buffer> <Esc> <c-c>

" Jedi just isn't fast enough with numpy/pandas/etc
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0

" Customize ArgWrap by filetype
autocmd! FileType python let b:argwrap_tail_comma=1
autocmd! FileType vim let b:argwrap_line_prefix='\'


"""""""""""""""""""""""""
"" Lualine Config """""
"""""""""""""""""""""""""

function! GitRepoForLualine()
  if winwidth(0) < 100
    return ''
  else
    let root = GetGitRoot()
    return root != '' ? fnamemodify(root, ':t') : 'None'
  endif
endfunction

lua << END
require('lualine').setup {
  theme = 'gruvbox',
  sections = {
    lualine_b = {'GitRepoForLualine', 'branch', 'diff', 'diagnostics'},
    lualine_x = {'encoding', 'filetype'},
  }
}
END


"""""""""""""""""""""""""""
"" Treesitter Config  """""
"""""""""""""""""""""""""""

lua << EOF
-- Enable native treesitter highlighting for all supported languages
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    -- pcall prevents an error if you open a filetype without a compiled parser
    pcall(vim.treesitter.start)
  end,
})
EOF


"""""""""""""""""""""""""""
""" LSP Config Things """"
"""""""""""""""""""""""""""

lua << EOF
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(args)

    vim.lsp.start({
      name = 'ruff',
      cmd = {'ruff', 'server'},
      root_dir = vim.fn.GetGitRoot(),
    })

    vim.lsp.start({
      name = 'pyright',
      cmd = {'pyright-langserver', '--stdio'},
      root_dir = vim.fn.GetGitRoot(),
      settings = {
        python = {
          analysis = {
            autoImportCompletions = true,
            typeCheckingMode = "basic",
          }
        }
      }
    })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    -- Sync call to fix everything (respects your ruff.toml / pyproject.toml)
    vim.lsp.buf.code_action({
      context = { only = { "source.fixAll" } },
      apply = true,
    })
    -- Final format pass
    vim.lsp.buf.format({ async = false })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', args.buf) then
      local group = vim.api.nvim_create_augroup("shea_lsp_highlights", { clear = false })
      vim.api.nvim_clear_autocmds({ group = group, buffer = args.buf })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
EOF


"""""""""""""""""""""""""""
"" Custom Keybindings """""
"""""""""""""""""""""""""""

let mapleader="\<SPACE>"

" Custom basic mappings
nnoremap <Leader><Leader> :
nnoremap <Leader>fs :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>e :e<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>y "+yy
vnoremap <Leader>y "+y
nnoremap <Leader>v "+p
nnoremap <Leader>bd :bd<CR>
nnoremap <Leader>bD :bd!<CR>
nnoremap <Leader>sc z=
nnoremap <Leader>sC z=

" Allow ESC from Terminal editing
tnoremap <Esc> <C-\><C-n>G

" Stay in visual mode when indenting
vnoremap < <gv
vnoremap > >gv

" Make it a little easier to jump between splits/windows
nnoremap <Leader><Tab> :b#<CR>
nnoremap <Leader>wv <C-W>v
nnoremap <Leader>wq <C-W>q
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
