#!/bin/bash

#   CloudPassage Halo Daemon
#   Unattended installation script for Adobe-Behance
#   -------------------------------------------------------------------------
#   This script is intended to be used for an unattended installation
#   of the CloudPassage Halo daemon.
#
#   IMPORTANT NOTES
#
#     * This script may require adjustment to conform to your server's
#       configuration. Please review this script and test it on a server
#       before using it to install the Halo daemon on multiple servers.
#
#     * This script contains the CloudPassage Halo Daemon Registration Key owned by
#       Adobe-Behance. Keep this script safe - handle it as
#       you would the password to your CloudPassage portal account!
#

# add CloudPassage repository
echo 'deb http://packages.cloudpassage.com/debian debian main' | sudo tee /etc/apt/sources.list.d/cloudpassage.list > /dev/null

# install curl
sudo apt-get -y install curl

# import CloudPassage public key
curl http://packages.cloudpassage.com/cloudpassage.packages.key | sudo apt-key add -

# update apt repositories
sudo apt-get update > /dev/null

# install the daemon
sudo apt-get -y install cphalo

# start the daemon for the first time
sudo /etc/init.d/cphalod start --daemon-key=$(cloudpassage_daemon_key) --grid=$(cloudpassage_grid_url)
