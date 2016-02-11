#!/bin/bash

UNAME=`uname`
DOTFILES_DIR=`dirname $0`/conf
DOTFILES_BAK=`dirname $0`/bak

realpath ()
{
	[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

print_var ()
{
	echo "UNAME=${UNAME}"
	echo "DOFILES_DIR=${DOTFILES_DIR}"
	echo "DOTFILES_BAK=${DOTFILES_BAK}"
}

install_for_darwin ()
{
	# install homebrew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#	brew tap thoughtbot/formulae
#	brew install rcm

	brew install git
}

install_for_linux ()
{
	apt-get -v >/dev/null 2>&1 || { echo "no apt-get found. exit 1" >&2; exit 1; }

	apt-get update
	sudo apt-get install git vim screen
}

install_common ()
{
	rm -rf ${DOTFILES_BAK}/*
	mkdir -p ${DOTFILES_BAK}

	for file in ${DOTFILES_DIR}/*
	do
		local file_basename=`basename $file`
		if [ -f ~/.$file_basename ]; then
			echo "backup $file_basename"
			mv ~/.$file_basename ${DOTFILES_BAK}/$file_basename
			echo "done"
		else
			echo "no $file_basename detected"
		fi

		echo "installing $file_basename"

		ln -s `realpath ${file}` ~/.$file_basename
		echo "done"
	done

	echo "install VundleVim"
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall

#	exec bash
}

main ()
{
	print_var

	if [ $UNAME = "Darwin" ]; then
		install_for_darwin
	elif [ $UNAME = "Linux" ]; then
		install_for_linux
	fi

	install_common
}

main
