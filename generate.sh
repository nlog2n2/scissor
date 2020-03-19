#!/bin/bash

# ssh-keygen setting
SSH_KEY_PATH=~/.ssh/nlog2n2-GitHub
SSH_CONFIG_PATH=~/.ssh/config
COMMENT_MESSAGE=git@github.com

# ssh config setting
CONNECTION_HOST=github
HOST_NAME=github.com
USER=git

# key create timestamp
TIMESTAMP=`date "+%Y%m%d-%H%M%S"`

echo "1. check install expect"
if ! sudo dnf list --installed expect | grep expect > /dev/null; then
    sudo dnf install -y expect
fi

echo "2. rm current ssh-key file "
for file in `eval ls ${SSH_KEY_PATH}*`;
    do if [ -e $file ];then rm $file ;fi
done

echo "3. generate password & ssh-key "
passpharase="`mkpasswd -l 16 -c 8 -C 4 -d 2 -s 0`"
ssh-keygen -t rsa -b 4096 -C $COMMENT_MESSAGE -P $passpharase -f $SSH_KEY_PATH > /dev/null

echo "4. check & generate ssh config "
if [ -e $SSH_CONFIG_PATH ] ; then 
    eval cp -a ${SSH_CONFIG_PATH} ${SSH_CONFIG_PATH}.${TIMESTAMP}
    eval rm ${SSH_CONFIG_PATH}
fi
touch $SSH_CONFIG_PATH
chmod 600 $SSH_CONFIG_PATH

echo "5. write ssh config "

eval echo  "Host $CONNECTION_HOST" >> $SSH_CONFIG_PATH
eval echo  "\	\	HostName $HOST_NAME" >> $SSH_CONFIG_PATH
eval echo  "\	\	IdentityFile $SSH_KEY_PATH" >> $SSH_CONFIG_PATH
eval echo  "\	\	User $USER" >> $SSH_CONFIG_PATH
eval echo  "\	\	IdentitiesOnly yes" >> $SSH_CONFIG_PATH

#while read line
#do
#    eval echo  $line >> $SSH_CONFIG_PATH
#done<<EOS
#"Host $CONNECTION_HOST"
#"\	\	HostName $HOST_NAME"
#"\	\	IdentityFile $SSH_KEY_PATH"
#"\	\	User $USER"
#"\	\	IdentitiesOnly yes"
#EOS

echo "6. setting ssh agent "
number_of_ssh_agents=`ps aux | grep ssh-agent | grep -v grep | wc -l`
if [ $number_of_ssh_agents -eq 0 ] ; then
    eval "$(ssh-agent -s)"
fi

echo $passpharase > $SSH_KEY_PATH.$TIMESTAMP

expect -c "
set timeout 5
spawn ssh-add ${SSH_KEY_PATH}
expect -re \"^Enter.*:\"
send \"$passpharase\n\"
expect \"$\"
exit 0
"

# view public key
echo "7. view public key "
eval cat "$SSH_KEY_PATH.pub"
echo "==================================="
echo "8. complete  "
echo "==================================="
echo "excute this test command on your terminal" 
echo ssh -T "$USER@$HOST_NAME"
echo "password: $passpharase"
