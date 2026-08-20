# dotfiles

Personal shell, git, vim and screen configuration, kept in one repo and
symlinked into `$HOME`.

| File | Linked to | What it is |
| --- | --- | --- |
| `conf/aliases` | `~/.aliases` | Shared aliases, sourced by both bash and zsh |
| `conf/bash_profile` | `~/.bash_profile` | Bash options, completion, and dotfile loading |
| `conf/bash_prompt` | `~/.bash_prompt` | Solarized bash prompt with git status |
| `conf/bashrc` | `~/.bashrc` | Sources `~/.bash_profile` |
| `conf/zshrc` | `~/.zshrc` | oh-my-zsh setup: bullet-train theme, typing hints |
| `conf/gitconfig` | `~/.gitconfig` | Git aliases and colors |
| `conf/vimrc` | `~/.vimrc` | Vim options and Vundle plugins |
| `conf/screenrc` | `~/.screenrc` | GNU screen status line and key bindings |

## Install

```bash
git clone https://github.com/TingyuHuang/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Then restart your shell, or `source ~/.zshrc` (`source ~/.bashrc` for bash).

`install.sh` will:

1. Install the packages it needs — Homebrew and git on macOS, or
   `git vim screen zsh` via `apt-get` on Debian/Ubuntu.
2. Symlink every file in `conf/` to `~/.<name>`, moving anything already at
   that path into `bak/<timestamp>/` first.
3. Install [Vundle](https://github.com/VundleVim/Vundle.vim) and the plugins
   listed in `conf/vimrc`.
4. Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) plus the
   [bullet-train](https://github.com/caiogondim/bullet-train.zsh) theme.
5. Install the zsh plugins listed in `conf/zshrc`:
   [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
   (grey hint from your history while typing, right arrow accepts it) and
   [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
   (colours the command line, unknown commands turn red).

The script is safe to re-run: files that are already linked are left alone,
and nothing is ever overwritten in place.

## Local overrides

`~/.extra` is sourced by both shells if it exists and is not tracked here —
put machine-specific paths, tokens and anything else you don't want to commit
in there. Bash additionally picks up `~/.path` and `~/.functions`.

## Uninstall

There is no uninstall script. To undo an install, remove the symlinks and
restore the most recent backup:

```bash
cd ~/dotfiles
for f in conf/*; do rm -f ~/."$(basename "$f")"; done

# then copy back whichever backup you want, e.g.
cp -a bak/20240101-120000/. ~/
```

oh-my-zsh has its own uninstaller (`uninstall_oh_my_zsh`), and Vundle can be
removed with `rm -rf ~/.vim/bundle`.
