ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim	
	ln -f -s $(ROOT_DIR)/snippets/ompsnippets $(HOME)/.vim/ompsnippets
	ln -f -s $(ROOT_DIR)/snippets/yobasnippets $(HOME)/.vim/yobasnippets
	vim +PluginInstall +qall
	cd $(HOME)/.vim/bundle/YouCompleteMe; ./install.sh --clang-completer; cd -
