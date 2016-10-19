#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.install


set_sshd_option() {
	file=$1
	key=$2
	value=$3

	if ! grep -q ^$key $file; then
		echo >>$file
		echo "$key $value" >>$file
	elif [ "$OSVER" = "netbsd-6" ]; then
		sed -e "s/^\($key\)[ ].*/\\1 $value/" $file >$file.$$
		cat $file.$$ >$file
	else
		sed -i -e "s/^\($key\)[ ].*/\\1 $value/" $file
	fi
}


echo "setting up secure sshd configuration"
file="/etc/ssh/sshd_config"
save_original_config $file

set_sshd_option $file Protocol 2
set_sshd_option $file UsePrivilegeSeparation yes
set_sshd_option $file HostbasedAuthentication no
set_sshd_option $file PubkeyAuthentication yes
set_sshd_option $file PermitEmptyPasswords no
set_sshd_option $file PermitRootLogin without-password
set_sshd_option $file StrictModes yes
set_sshd_option $file X11Forwarding no
set_sshd_option $file TCPKeepAlive yes

if [ "$USE_PASSWORD_AUTHENTICATION" = "disable" ]; then
	set_sshd_option $file PasswordAuthentication no
elif [ "$USE_PASSWORD_AUTHENTICATION" = "enable" ]; then
	set_sshd_option $file PasswordAuthentication yes
fi

case "$OSTYPE" in
	debian)
		service ssh reload
		;;
	redhat)
		service sshd reload
		;;
	netbsd)
		/etc/rc.d/sshd restart
		;;
	*)
		;;
esac
