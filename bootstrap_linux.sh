#!/bin/bash

echo Beginning setup of new dev environment.
mkdir ~/devapps
sudo apt-get update

echo Installing Neovim
sudo apt-get install fuse --yes
curl -L https://github.com/neovim/neovim/releases/download/v0.4.3/nvim.appimage -o ~/devapps/nvim.appimage
chmod u+x ~/devapps/nvim.appimage
echo 'export XDG_CONFIG_HOME=~' >> ~/.bashrc
echo 'alias nvim=~/devapps/nvim.appimage' >> ~/.bashrc

echo Installing MiniConda
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/devapps/miniconda-installer.sh
chmod u+x ~/devapps/miniconda-installer.sh
~/devapps/miniconda-installer.sh -b -p ~/devapps/miniconda

echo Finished bootstraping.  You should likely source ~/.bashrc now
