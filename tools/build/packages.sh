#!bin/bash

sudo apt-get update
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python2
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev libffi-dev wget
sudo apt-get install -y build-essential bc lld gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi libssl-dev libfl-dev curl git ftp lftp wget libarchive-tools ccache python2 python2-dev zip unzip tar gzip bzip2 rar unrar cpio jq llvm wget zstd
echo "Installing packages has been done"
