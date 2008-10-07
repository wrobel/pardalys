#!/bin/bash

# imports public keys into the ssh authorized_keys file

echo -n ">> Importing ssh keys.. "

[ ! -e /root ] && cp -r /etc/skel /root

# add keys into authorized keys
for KEY in `ls /var/spool/ec2/meta-data/public-keys` ; do
	cat "/var/spool/ec2/meta-data/public-keys/$KEY/openssh-key" >> /root/.ssh/authorized_keys
done

# normalize to prevent multiple keys being added
cat /root/.ssh/authorized_keys | uniq > /root/.ssh/.authorized_keys
mv /root/.ssh/.authorized_keys /root/.ssh/authorized_keys

# correct perms
chmod 600 /root/.ssh/authorized_keys

echo "done"
