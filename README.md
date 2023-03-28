# Install dotfiles

To install dotfiles, run following commands

```=script
# install git
sudo apt install git

# install dotfiles
cd ~ && git clone https://github.com/TingyuHuang/dotfiles.git && cd dotfiles && ./install.sh
source ~/.bashrc
```

which backup your dotfiles to dotfiles/bak/ and link new dotfiles to your home directory.

# Uninstall dotfiles

Not available.
