# neovim-config
Home for my personal configuration of NeoVim.

## Why NeoVim?

I like the philosophy of emacs, but the pragmatism of vim.  I like the community around neovim.

## Packaging Decision

I went with Pathogen combined with git submodules.  Somewhat to keep it simple.  Somewhat to be in complete control of when a plugin is updated.  And partly to keep myself familiar with git submodules.

## Installing Neovim

Install NeoVim with the standard NeoVim instructions.  They are currently pushing folks to use the AppImage style.

(I'm done trying with Windows, but if you look in the git history here you can find some out-of-date Windows instructions.)

## Cloning this config

Clone this repo directly into your desired/configured config location.

If you want the nested package submodules (e.g. `parso` for `vim-jedi`), then do a `git clone --recursive ...`.

If you don't want the nested package submodules (e.g. you will provide `jedi` yourself), then the following combo will omit the nested submodules:

```
git clone ...
git submodule init
git submodule update
```

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
