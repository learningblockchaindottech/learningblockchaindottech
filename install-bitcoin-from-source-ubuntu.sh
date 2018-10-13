#!/bin/bash
# ./install-bitcoin-from-source-ubuntu.sh
# Author: Bryan Gmyrek <bryangmyrekcom@gmail.com>
# License: MIT
# Enable error checking (snippet=basherror!)
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value
error() {
  echo "Error on or near line ${1}: ${2:-}; exiting with status ${3:-1}"
  exit "${3:-1}"
}
trap 'error ${LINENO}' ERR

echo "This script is only intended to be used to install a fresh version of Bitcoin on Ubuntu."
echo "No warranty is expressed or implied and if you chose to run this on an existing Bitcoin install you do so at your own risk (ABBU - Always Be Backing Up)."
echo "This script prints out everything it is doing (usually mutiple times)"
echo "This is so that if/when things go wrong, you can fix them."
echo "Many packages will be installed/removed automaticaly. If you're not sure if this is OK, inspect the source code of this script first and/or run the commands independently."
echo "You should be able to re-run the script after fixing a failed step, and it will retry a few steps and start where it left off."

while true; do
    read -p "Do you wish to continue [yes or no]?" yn
    case $yn in
        [Yy]* ) echo "OK!"; break;;
        [Nn]* ) echo "Bye!"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Comment out set -o verbose and set -o xtrace if you want to see less verbose output.
set -o verbose   # show commands as they are executed
set -o xtrace    # expand variables

cd $HOME

echo "Attempting to install the Bitcoin source code at ~/code/bitcoin"

ls code || mkdir code

cd code

which git || sudo apt-get -y install git

ls bitcoin || git clone https://github.com/bitcoin/bitcoin.git

echo "Setting up a swapfile to ensure we can compile bitcoin."

if ls /swapfile; then
        echo "Swapfile appears to exist, skipping."
else
    sudo fallocate -l 4G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi

echo "Installing dependencies for Bitcoin."

sudo add-apt-repository ppa:bitcoin/bitcoin

sudo apt-get update

#First ensure you have build essentials installed:
sudo apt-get -y install build-essential

#Install Autoconf:
sudo apt-get -y install autoconf

#Install Automake:
sudo apt-get -y install automake

#Install Boost:
sudo apt-get -y install libboost-all-dev

#Install Libtool:
sudo apt-get -y install libtool

#Install Libevent:
sudo apt-get -y install libevent-dev

#Install Libevent:
sudo apt-get -y install pkg-config

#Install Berkley DB:
sudo apt-get install libdb4.8-dev libdb4.8++-dev

#Install Open SSL:
sudo apt-get -y install libssl-dev

echo "Setting up .bitcoin configuration directory."

cd $HOME

ls .bitcoin || mkdir .bitcoin

cd $HOME/.bitcoin

cd $HOME/code/bitcoin

if [ -x bitcoin ]; then
    echo "The 'bitcoin' daemon appears to be built already. Skipping make."
else
    echo "Building Bitcoin daemon from source code."

    ./autogen.sh

    ./configure

    make

    echo "Build process complete."
fi

echo "Process complete."
echo "Bitcoin should be installed in ${HOME}/code/bitcoin"
echo "Remember to back up your ${HOME}/.bitcoin/wallet.dat file on e.g. a USB drive after starting Bitcoin for the first time."
echo "Have a nice day."
