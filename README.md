# neovim-config
Home for my personal configuration of NeoVim.

## Why NeoVim?

For those watching my github activity, it's going to look like I just can't figure out what I want.  And they'd be right.  But still, why NeoVim:
  - I do mostly Python development.
  - I don't like full IDEs (e.g. PyCharm)
  - I really like vim keybindings.
  - Magit performance is just unbearable these days in Windows.
  - In theory I can integrate Python REPLs with NeoVim terminals.

## Installation / Setup

For now I'm sourcing NeoVim from chocolatey.  Should likely snag `git.portable`, `fzf` and `neovim` from `choco`.  Then be sure to get the following directories on your `%PATH%`:
  - `c:\tools\git\usr\bin`
  - `c:\tools\git\mingw64\bin`
  - `c:\tools\neovim\neovim\bin`

NeoVim is helping champion `%XDG_CONFIG_HOME%`, so set that somewhere appropriate (e.g. `%UserProfile%`).  Then clone this repo into `%XDG_CONFIG_HOME%/nvim`.

To bootstrap the plugins clone Shougo/dein.vim into `%UserProfile%/repos/vim-plugins/repos/github.com/Shougo/dein.vim`.  Then launch NeoVim and run `:call dein#install()`.

An `Open with NeoVim` entry for Windows Explorer can be created by importing `open_with_neovim.reg` using `regedit` (when ran as administrator).

There is one git default that is worth changing to play ~better with ~Fugitive IMHO.  I prefer to have it infer the desired upstream when I push, and that's not the default to make git noobs be explicit.  To make it the default, change your `.gitconfig` thusly:
`git config --global push.default current`

