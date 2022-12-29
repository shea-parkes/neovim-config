# neovim-config
Home for my personal configuration of NeoVim.

## Why NeoVim?

I like the philosophy of emacs, but the pragmatism of vim.  I like the community around neovim.

## Packaging Decision

I went with Pathogen combined with git submodules.  Somewhat to keep it simple.  Somewhat to be in complete control of when a plugin is updated.  And partly to keep myself familiar with git submodules.

## Installation / Setup (Windows)

I'm currently done using NeoVim on windows.  Look in the git history here for some out-of-date sourcing instructions.

## Installation / Setup (Linux)

Install NeoVim with the standard NeoVim instructions.  They are currently pushing folks to use the AppImage style.

Clone this repo into your desired/configured config location (with the `--recursive` flag to get the plugin submodules).  Consider going in and deleting the nested submodules of `vim-jedi` (this forces that plugin to use `jedi` from your active virtualenv).

## Updating plugins

For the most part just follow other instructions for updating git submodules.  Since the git submodule functionality has changed a lot during the life of git, I've included some ~current instructions here.

You should be able to do a `git submodule update --remote` to pull down all the updates.  Then you'll need to commit the changes that occurred in the `bundle` directory.  You actually don't want to `git submodule update --recursive --remote` because that will likely introduce incompatibilities in the nested submodules (their authors froze them for a reason).  However, if a plugin with submodules is updated, you should likely then run `git submodule update --recursive` (after committing the plugin updates themselves to this repository) to catch intentional nested submodule updates.

The `.gitmodules` file in this repository can be inspected to see what submodules there are (and what branch they're setup to track).

Some plugins will require re-running `:UpdateRemotePlugins` after updating (e.g. `semshi`).

After doing an update, consider running Pathogen's `:Helptags` to go through and build any necessary plugin documentation (many plugins seem to commit their docs directly, so this only affects a few).

Of course, running `:Helptags` unfortunately modifies the submodules.  You'll likely want to cleanup those modifications before doing a plugin update with something like:
```
git submodule foreach git clean -xfd
git submodule foreach git reset head --hard
```
