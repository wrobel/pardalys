#!/bin/bash

# As a default we use the "binpkg" target for binary pacakges. This is the
# personal upload space for G. Wrobel though.
if [ -z "$1" ]; then
    target="binpkg"
else
    target=$1
fi

if [ ! -e "/root/.ec2-keys" ]; then
    echo "Please place your EC2 keys in /root/.ec2-keys as in the following example:"
    echo
    echo "export AMAZON_ACCESS_KEY_ID=\"abcdefghijklmnopqrstuvwxyz\""
    echo "export AMAZON_SECRET_ACCESS_KEY=\"abcdefghijklmnopqrstuvwxyz\""
    exit 1;
fi

. /root/.ec2-keys

if [ ! -e "/mnt/s3" ]; then
    mkdir /mnt/s3
fi

if [ -z "`ls /mnt/s3`" ]; then
    /usr/bin/s3fs $target -o accessKeyId=$AMAZON_ACCESS_KEY_ID -o secretAccessKey=$AMAZON_SECRET_ACCESS_KEY /mnt/s3
fi

rsync -avz --delete-after /usr/portage/packages/All/ /mnt/s3/

cd /mnt/s3

php -- > index.html <<EOF
<?php
\$title = "Directory index";
 
echo "<html><title>\$title</title><body>";
echo "<h1>\$title</h1>";
 
\$dir = opendir(".");
while ((\$file = readdir(\$dir)) !== false)
  {
    if (\$file[0] == ".")
      continue;
    echo "<a href=\"http://$target.s3.amazonaws.com/\$file\">\$file</a></br>";
  }
closedir(\$dir);
 
echo "</body></html>";
?>
EOF

s3sh <<EOF
a = Bucket.find("$target")
a.objects.each {|file| file.acl.grants << ACL::Grant.grant(:public_read); file.acl(file.acl)}
EOF
