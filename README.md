# neovim-config
Home for my personal configuration of NeoVim.

## Why NeoVim?

For those watching my github activity, it's going to look like I just can't figure out what I want.  And they'd be right.  But still, why NeoVim:
  - I do mostly Python development.
  - I'm still stuck on Windows.
  - I don't like full IDEs (e.g. PyCharm).
  - I really like vim keybindings.
  - Magit performance is just unbearable these days in Windows.
  - NeoVim terminals on Windows work well with Python REPLs.

## Installation / Setup

For now I'm sourcing NeoVim from chocolatey.  Should likely snag `git.portable`, `fzf` and `neovim` from `choco`.  If you want tag support you currently have to manually grab a Windows build of Universal Ctags from [here](https://github.com/universal-ctags/ctags-win32). Then be sure to get the following directories on your `%PATH%`:
  - `c:\tools\git\usr\bin`
  - `c:\tools\git\mingw64\bin`
  - `c:\tools\neovim\neovim\bin`
  - Wherever you unzipped `ctags.exe`... (Making sure `ctags.exe` that is bundled with Emacs isn't higher on your `%PATH%`)

NeoVim respects `%XDG_CONFIG_HOME%`, so set that somewhere appropriate (e.g. `%UserProfile%`).  Then clone this repo into `%XDG_CONFIG_HOME%/nvim`.

I've moved to using submodules for plugin management.  Partly to simplify my `init.vim` and partly to learn more about git submodules.  Because of this, please be sure to clone submodules as well.  Either with an initial `git clone --recursive`, or if you've already cloned the root repository you'll need to run `git submodule update --init --recursive`.

An `Open with NeoVim` entry for Windows Explorer can be created by importing `open_with_neovim.reg` using `regedit` (when ran as administrator).

There is one git default that is worth changing to play ~better with ~Fugitive IMHO.  I prefer to have it infer the desired upstream when I push, and that's not the default to make git noobs be explicit.  To make it the default, change your `.gitconfig` thusly:
`git config --global push.default current`

I'm also trying out [tig](https://github.com/jonas/tig) (still missing magit...).  The default line graphics don't work well on Windows, so I suggest a `git config --global tig.line-graphics ascii`.

Since I do a lot of python development, a few of the neovim plugins depend upon having `python` on the `%PATH%`.  It should likely be a `python` in a ~virtual/conda environment with the `jedi` and `neovim` packages installed.  You can confirm this was done correctly by running `:checkhealth`.

## Updating plugins

For the most part just follow other instructions for updating git submodules.  Since the git submodule functionality has changed a lot during the life of git, I've included some ~current instructions here.

You should be able to do a `git submodule update --remote` to pull down all the updates.  Then you'll need to commit the changes that occurred in the `bundle` directory.  You actually don't want to `git submodule update --recursive --remote` because that will likely introduce incompatibilities in the nested submodules (their authors froze them for a reason).  However, if a plugin with submodules is updated, you should likely then run `git submodule update --recursive` (after committing the plugin updates themselves to this repository) to catch intentional nested submodule updates.

The `.gitmodules` file in this repository can be inspected to see what submodules there are (and what branch they're setup to track).

After doing an update, consider running Pathogen's `:Helptags` to go through and build any necessary plugin documentation (many plugins seem to commit their docs directly, so this only affects a few).

Of course, running `:Helptags` unfortunately modifies the submodules.  You'll likely want to cleanup those modifications before doing a plugin update with something like:
```
git submodule foreach git clean -xfd
git submodule foreach git reset head --hard
```

## Uncommon plugin choices

A couple plugins I chose have much more popular alternatives.  Here's why I went with what I did:

  * `accio` for linting
    * `syntastic` is classic, but it never got around to getting async, and it doesn't look like it ever will.
    * `ale` is very focused on linting while you type, but `pylint` doesn't work with that.  In actuality, `ale`'s `pylint` performance was quite bad (blocking on entry and save).
    * None of `neomake`, `dispatch` nor `asyncrun` natively mark lines, and the venerable `errormarker` is long in the tooth (and doesn't like `nvim-qt`).
  * `completor.vim` for completion
    * I want auto-popups, and `pandas` means they have to be async to be sane.
    * This was the lightest weight plugin I could find that supports `jedi` without an LSP wrapper.

### PowerShell Notes

These don't really belong here, but I don't feel like making their own home ATM.  Here are some PowerShell tools I'm using to survive my weaning from `cmd.exe`:
  * Don't forget to trust your own scripts: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`
  * Grab [posh-git](https://github.com/dahlbyk/posh-git).
    * Install it: `PowerShellGet\Install-Module posh-git -Scope CurrentUser`
    * Load it manually once: `Import-Module posh-git`
    * Then add it to your profile to load everytime: `Add-PoshGitToProfile`
  * Make `conda` work with PowerShell:
    * First check if they ever fixed it to work natively: https://github.com/conda/conda/issues/626
    * Assuming they haven't, likely make use of this community solution: https://github.com/BCSharp/PSCondaEnvs
    * Do so by installing a special conda package into your root environment: `conda install -n root -c pscondaenvs pscondaenvs`
  * Make it possible to load up environment variables from legacy batch scripts.
    * There are many PowerShell plugins to do this.  Most provide a function named `Invoke-BatchFile`
    * I'm currently using the (likely overkill) [PowerShell Community Extensions](https://github.com/Pscx/Pscx)
      * Installed way too broadly via: `Install-Module Pscx -Scope CurrentUser`

PowerShell can be used to create a nice shortcut on the Windows taskbar as well.  Make a shortcut to `powershell.exe`, then edit the shortcut to add a custom `.ps1` file as an argument (one that sets up any environment and then calls `nvim-qt.exe --maximized`).  This works better than a `.bat` file (which doesn't seem to want to bring `nvim-qt.exe` into focus).

Powershell profile located at https://gist.github.com/cbusenbu/785669c300f0f8d19aaa38685ff94394

### Hub notes

Don't forget to install hub locally.

Also gitconfig located at https://gist.github.com/cbusenbu/785669c300f0f8d19aaa38685ff94394
