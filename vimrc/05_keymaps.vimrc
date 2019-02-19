
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
nnoremap <Leader>E :e!<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>y "+yy
vnoremap <Leader>y "+y
nnoremap <Leader>v "+p
nnoremap <Leader>bd :bd<CR>
nnoremap <Leader>bD :bd!<CR>
nnoremap <Leader>sc z=
nnoremap <Leader>sC z=

" Tabs Mapping
" :tabs list all
" :tabn next tab
" :tabp previous tab
nnoremap <Leader>tt :tabs<CR>
nnoremap <Leader>ts :tab split<CR>
nnoremap <Leader>tf :tabfirst<CR>
nnoremap <Leader>tl :tablast<CR>
nnoremap <Leader>tn :tabn<CR>
nnoremap <Leader>tp :tabp<CR>

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
nnoremap <Leader>/w "zyiw:exe "BLines ".@z.""<CR>

" Git related mappings
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gm :Merginal<CR>
nnoremap <Leader>gb :Merginal<CR>
nnoremap <Leader>gf :Gfetch --prune<CR>
nnoremap <Leader>gF :Gpull<CR>
nnoremap <Leader>gP :Gpush --set-upstream<CR>
nnoremap <Leader>gp :Gpush<CR>
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
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

" And play nice with delimitMate
imap <expr> <CR> pumvisible() ? "\<C-y>" : "<Plug>delimitMateCR"

" Expose functions created in custom.vimrc
map <Leader>si :call LaunchIPython()<CR>
map <Leader>sr :call SendToTerminal()<CR>
map <Leader>ss :call SendNudgeToTerminal()<CR>
