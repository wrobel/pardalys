#!/bin/bash

# extracts ec2 metadata into /var/spool/ec2/meta-data

INSTANCE_DATA_HOST="http://169.254.169.254/latest"
METADATA_HOST="$INSTANCE_DATA_HOST/meta-data"
USERDATA_HOST="$INSTANCE_DATA_HOST/user-data"
METADATA_DIR=/var/spool/ec2/meta-data
USERDATA_FILE=/var/spool/ec2/user-data

rm -rf $METADATA_DIR
rm -f $USERDATA_FILE
mkdir -p $METADATA_DIR

METADATA_KEYS=`wget -q -O - $METADATA_HOST | grep -v /`
METADATA_DIRS=`wget -q -O - $METADATA_HOST | grep / | grep -v public-keys`

echo -n ">> Getting meta-data.. "

# enumerate simple metadata keys
for KEY in $METADATA_KEYS ; do
	wget -q -O - "$METADATA_HOST/$KEY" > $METADATA_DIR/$KEY
done

# enumerate metadata directories (nested directories unsupported)
for DIR in $METADATA_DIRS ; do
	DIR=`basename $DIR`
	mkdir $METADATA_DIR/$DIR
	for KEY in `wget -q -O - $METADATA_HOST/$DIR` ; do
		wget -q -O - "$METADATA_HOST/$DIR/$KEY" > $METADATA_DIR/$DIR/$KEY
	done
done

# enumerate public keys (slightly different format)
for PUBKEY in `wget -q -O - "$METADATA_HOST/public-keys/" | sed 's/=.*//'` ; do
	KEYFILE=$METADATA_DIR/public-keys/$PUBKEY/openssh-key
	mkdir -p `dirname $KEYFILE`
	wget -q -O - "$METADATA_HOST/public-keys/$PUBKEY/openssh-key" > $KEYFILE
done

# fetch raw user data
wget -q -O - "$USERDATA_HOST" > $USERDATA_FILE

echo "done"

exit 0
