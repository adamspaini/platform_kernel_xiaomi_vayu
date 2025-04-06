#!bin/bash

sudo apt-get update
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python2
sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev libffi-dev wget

wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
tar -xvzf Python-2.7.18.tgz
cd Python-2.7.18
./configure --enable-optimizations
make
sudo make altinstall
sudo apt-get install -y build-essential bc lld gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi libssl-dev libfl-dev curl git ftp lftp wget libarchive-tools ccache python2 python2-dev zip unzip tar gzip bzip2 rar unrar cpio jq llvm wget zstd
echo "Installing packages has been done"
