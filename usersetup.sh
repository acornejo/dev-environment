#!/bin/bash

set -ex

USER=coder
CODE_SERVER=/opt/code-server/bin/code-server

echo 'PATH=/opt/python/bin:/opt/golang/bin:/opt/nodejs/bin:$PATH' > /etc/profile.d/path.sh
echo 'export PATH' >> /etc/profile.d/path.sh

adduser --gecos '' --disabled-password ${USER} && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

if [ -e "${CODE_SERVER}" ]; then
	sudo -i -u ${USER} ${CODE_SERVER} --install-extension 'ms-python.python'
	sudo -i -u ${USER} ${CODE_SERVER} --install-extension 'ms-toolsai.jupyter'
	sudo -i -u ${USER} ${CODE_SERVER} --install-extension 'golang.Go'
	sudo -i -u ${USER} ${CODE_SERVER} --install-extension 'vscodevim.vim'
	# curl -L https://github.com/microsoft/vscode-cpptools/releases/download/v1.18.0/cpptools-linux.vsix > /tmp/cpptools.vsix && \
	#    sudo -i -u ${USER} ${CODE_SERVER} --install-extension /tmp/cpptools.vsix && \
	#    rm -f /tmp/cpptools.vsix
fi

if [ -e $(which git) ]; then
	sudo -i -u ${USER} git clone https://github.com/acornejo/dotfiles.git ${HOME}/.dotfiles
	sudo -i -u ${USER} ${HOME}/.dotfiles/install.sh
fi
