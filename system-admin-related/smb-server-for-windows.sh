#!/bin/bash
sudo apt update && sudo apt -y install bash-completion
sudo apt install -y samba
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.asc
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install gcsfuse    
sleep 2

mkdir -p /samba/share
sudo chown -R nobody:nogroup /samba/share
sudo chmod -R 777 /samba/share
sudo vi /etc/samba/smb.conf

# Add the following uncommented to /etc/samba/smb.conf
# [share]
#   path = /samba/share
#   browsable = yes
#   writable = yes
#   guest ok = yes
#   read only = no
#   create mask = 7777

sudo systemctl restart smbd.service nmbd.service

sudo mount -t gcsfuse -o implicit_dirs,allow_other,uid=65534,gid=65534 MY_BUCKET /samba/share

echo "MY_BUCKET /samba/share gcsfuse rw,_netdev,user_allow_other,uid=65534,gid=65534" >> /etc/fstab

# While in Windows Server, go to "This PC", right click "This PC" and click "add a network location", later type in:

# \\ip-address\share