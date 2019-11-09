#!/bin/bash

echo Beginning setup of new dev environment.
mkdir ~/devapps
sudo apt-get update
echo 'if [ -f ~/.bashrc  ]; then' > .bash_profile
echo '   source ~/.bashrc' >> .bash_profile
echo 'fi' >> .bash_profile

echo Configuring git
git config --global push.default current
git clone git@github.com:magicmonty/bash-git-prompt ~/.bash-git-prompt --depth=1
echo 'GIT_PROMPT_ONLY_IN_REPO=1' >> ~/.bashrc
echo 'source ~/.bash-git-prompt/gitprompt.sh' >> ~/.bashrc

echo Installing Neovim
sudo apt-get install fuse --yes
curl -L https://github.com/neovim/neovim/releases/download/v0.4.3/nvim.appimage -o ~/devapps/nvim.appimage
chmod u+x ~/devapps/nvim.appimage
echo 'export XDG_CONFIG_HOME=~' >> ~/.bashrc
echo 'alias nvim=~/devapps/nvim.appimage' >> ~/.bashrc
git config --global core.editor "~/devapps/nvim.appimage"

echo Installing MiniConda
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/devapps/miniconda-installer.sh
chmod u+x ~/devapps/miniconda-installer.sh
~/devapps/miniconda-installer.sh -b -p ~/devapps/miniconda
~/devapps/miniconda/bin/conda init bash

echo Adding some python/neovim packages to root conda environment
~/devapps/miniconda/bin/conda install msgpack-python -y
~/devapps/miniconda/bin/conda install greenlet -y
~/devapps/miniconda/bin/pip install pynvim
~/devapps/miniconda/bin/conda install jedi -y
~/devapps/miniconda/bin/conda install pylint -y

echo Finished bootstraping.  You should likely source ~/.bashrc now
