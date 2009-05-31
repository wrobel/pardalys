#!/bin/bash

BINDIR=${BINDIR-/usr/bin}

# initialize all ec2 data

$BINDIR/ec2-get-metadata.sh
$BINDIR/ec2-import-sshkeys.sh

# set permissions on the /tmp dir
chmod 777 /tmp

MYHOST=`cat /var/spool/ec2/meta-data/public-hostname`
sed -i -e "s/^\(127.0.0.1\s*\)/\1$MYHOST /" /etc/hosts
