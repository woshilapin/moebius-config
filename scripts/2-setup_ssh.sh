#!/bin/bash

if which ssh-copy-id
then
	print_info "Transfer the SSH public key (password: raspi)"
	ssh-copy-id -i ~/.ssh/woshilapin@gmail.com.rsa.pub root@tuziwo-no-ip.org
else
	print_info "Create the SSH directory on raspberrypi (password: raspi)"
	ssh root@tuziwo.no-ip.org "mkdir -p ~/.ssh/"
	print_info "Transfer the SSH public key (password: raspi)"
	scp $HOME/.ssh/woshilapin@gmail.com.rsa.pub root@tuziwo.no-ip.org:~/.ssh/authorized_keys
fi
if ssh-add -l | grep 'woshilapin@gmail\.com\.rsa' > /dev/null
then
	print_info "Your SSH key is already connect to the ssh-agent"
else
	print_info "Add your SSH key to the ssh-agent"
	ssh-add ~/.ssh/woshilapin@gmail.com.rsa
fi
