#!/bin/bash

set -ex

CODE_SERVER=/opt/code-server/bin/code-server

if [ -e "${CODE_SERVER}" ]; then
	${CODE_SERVER} --install-extension 'ms-python.python'
	${CODE_SERVER} --install-extension 'ms-toolsai.jupyter'
	${CODE_SERVER} --install-extension 'golang.Go'
	${CODE_SERVER} --install-extension 'vscodevim.vim'
	# curl -L https://github.com/microsoft/vscode-cpptools/releases/download/v1.18.0/cpptools-linux.vsix > /tmp/cpptools.vsix && \
	#    /opt/code-server/bin/code-server --install-extension /tmp/cpptools.vsix && \
	#    rm -f /tmp/cpptools.vsix
fi

if [ -e $(which git) ]; then
	git clone https://github.com/acornejo/dotfiles.git ${HOME}/.dotfiles
	${HOME}/.dotfiles/install.sh
fi
