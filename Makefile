ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all:	
	ln -s $(ROOT_DIR)/.vimrc  ~/.vimrc 
	ln -s $(ROOT_DIR)/.tmux.conf ~/.tmux.conf 
	ln -s $(ROOT_DIR)/.zshrc ~/.zshrc
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall
	cd ~/.vim/bundle/YouCompleteMe; ./install.py --clang-completer; cd -
	ln -s $(ROOT_DIR)/clang-format.py ~/.vim/clang-format.py
	ln -s $(ROOT_DIR)/UltiSnips ~/.vim/UltiSnips
