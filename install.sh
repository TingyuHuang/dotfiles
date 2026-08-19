#!/usr/bin/env bash
#
# Install the dotfiles in this repository.
#
# Every file in conf/ is symlinked into $HOME as ~/.<name>. Anything already
# sitting at that path is moved into bak/<timestamp>/ first. Re-running is
# safe: existing links are left alone and nothing is overwritten in place.

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
DOTFILES_DIR="${DOTFILES_ROOT}/conf"
DOTFILES_BAK="${DOTFILES_ROOT}/bak/$(date +%Y%m%d-%H%M%S)"
UNAME="$(uname)"

log ()  { printf '==> %s\n' "$*"; }
warn () { printf 'warning: %s\n' "$*" >&2; }
die ()  { printf 'error: %s\n' "$*" >&2; exit 1; }
has ()  { command -v "$1" > /dev/null 2>&1; }

print_var ()
{
	echo "UNAME=${UNAME}"
	echo "DOTFILES_DIR=${DOTFILES_DIR}"
	echo "DOTFILES_BAK=${DOTFILES_BAK}"
}

install_for_darwin ()
{
	if ! has brew; then
		log "install homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		# Make brew usable for the rest of this run.
		for prefix in /opt/homebrew /usr/local; do
			if [ -x "${prefix}/bin/brew" ]; then
				eval "$("${prefix}/bin/brew" shellenv)"
				break
			fi
		done
	fi

	has brew || die "homebrew install failed"
	has git  || { log "install git"; brew install git; }
}

install_for_linux ()
{
	has apt-get || die "no apt-get found; install git vim screen zsh yourself, then re-run"

	sudo apt-get update
	sudo apt-get install -y git vim screen zsh
}

link_dotfiles ()
{
	local file name target

	for file in "${DOTFILES_DIR}"/*; do
		[ -e "${file}" ] || continue

		name=".$(basename "${file}")"
		target="${HOME}/${name}"

		if [ -L "${target}" ] && [ "$(readlink "${target}")" = "${file}" ]; then
			log "${name} already linked"
			continue
		fi

		if [ -e "${target}" ] || [ -L "${target}" ]; then
			mkdir -p "${DOTFILES_BAK}"
			mv "${target}" "${DOTFILES_BAK}/${name}"
			log "backed up ${name} to ${DOTFILES_BAK}"
		fi

		ln -s "${file}" "${target}"
		log "linked ${name}"
	done
}

install_vim_plugins ()
{
	local vundle="${HOME}/.vim/bundle/Vundle.vim"

	has vim || { warn "no vim found; skipping vim plugins"; return; }

	if [ -d "${vundle}" ]; then
		log "Vundle already installed"
	else
		log "install Vundle"
		git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git "${vundle}"
	fi

	vim +PluginInstall +qall
}

install_oh_my_zsh ()
{
	local omz="${HOME}/.oh-my-zsh"
	local themes="${omz}/custom/themes"
	local tmp

	if [ -d "${omz}" ]; then
		log "oh-my-zsh already installed"
	else
		log "install oh-my-zsh"
		# --keep-zshrc leaves our ~/.zshrc symlink alone, --unattended skips
		# both the chsh prompt and the "start a new shell now" handoff.
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
			"" --unattended --keep-zshrc
	fi

	if [ -f "${themes}/bullet-train.zsh-theme" ]; then
		log "bullet-train theme already installed"
		return
	fi

	log "install bullet-train theme"
	tmp="$(mktemp -d)"
	trap 'rm -rf "${tmp}"' RETURN
	git clone --depth 1 https://github.com/caiogondim/bullet-train.zsh.git "${tmp}/bullet-train"
	mkdir -p "${themes}"
	cp "${tmp}/bullet-train/bullet-train.zsh-theme" "${themes}/"
}

main ()
{
	print_var

	if [ "${UNAME}" = "Darwin" ]; then
		install_for_darwin
	elif [ "${UNAME}" = "Linux" ]; then
		install_for_linux
	else
		warn "unsupported platform ${UNAME}; only linking dotfiles"
	fi

	link_dotfiles
	install_vim_plugins
	install_oh_my_zsh

	log "done. restart your shell to pick up the new config."
}

# Allow sourcing this file (e.g. from a test) without running the install.
if [ "${BASH_SOURCE[0]:-$0}" = "${0}" ]; then
	main "$@"
fi
