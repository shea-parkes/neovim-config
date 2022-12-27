# neovim-config
Home for my personal configuration of NeoVim.

## Why NeoVim?

I like the philosophy of emacs, but the pragmatism of vim.  I like the community around neovim.

## Installation / Setup (Windows)

I'm currently done using NeoVim on windows.  Look in the git history here for some out-of-date sourcing instructions.

## Installation / Setup (Linux)

Follow the standard NeoVim instructions.  Currently pushing folks to use the AppImage style.

If you use something like `%XDG_CONFIG_HOME%`, you'll need to modify the pathogen loading call in `init.vim`.

## Updating plugins

For the most part just follow other instructions for updating git submodules.  Since the git submodule functionality has changed a lot during the life of git, I've included some ~current instructions here.

You should be able to do a `git submodule update --remote` to pull down all the updates.  Then you'll need to commit the changes that occurred in the `bundle` directory.  You actually don't want to `git submodule update --recursive --remote` because that will likely introduce incompatibilities in the nested submodules (their authors froze them for a reason).  However, if a plugin with submodules is updated, you should likely then run `git submodule update --recursive` (after committing the plugin updates themselves to this repository) to catch intentional nested submodule updates.

The `.gitmodules` file in this repository can be inspected to see what submodules there are (and what branch they're setup to track).

Some plugins will require re-running `:UpdateRemotePlugins` after updating (e.g. `numirias/semshi`).

After doing an update, consider running Pathogen's `:Helptags` to go through and build any necessary plugin documentation (many plugins seem to commit their docs directly, so this only affects a few).

Of course, running `:Helptags` unfortunately modifies the submodules.  You'll likely want to cleanup those modifications before doing a plugin update with something like:
```
git submodule foreach git clean -xfd
git submodule foreach git reset head --hard
```

## Uncommon plugin choices

A couple plugins I chose have much more popular alternatives.  Here's why I went with what I did:

  * `completor.vim` for completion
    * I want auto-popups, and `pandas` means they have to be async to be sane.
    * This was the lightest weight plugin I could find that supports `jedi` without an LSP wrapper.
