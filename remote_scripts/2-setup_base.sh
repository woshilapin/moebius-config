#!/bin/bash

source $SCRIPTS_PATH/functions.sh

### Install man-pages
print_info "Installing manpages"
yes | apt-get install man-db manpages
yes | apt-get install manpages-fr manpages-fr-dev manpages-fr-extra
yes | apt-get install manpages-posix manpages-posix-dev

### Install Git
print_info "Installing git"
yes | apt-get install git git-doc git-svn git-flow git-extras

### Install ZSH
print_info "Installing zsh"
yes | apt-get install zsh zsh-doc

### Install Vim
print_info "Installing vim (with exiberant-ctags)"
yes | apt-get install vim vim-doc exuberant-ctags cscope
