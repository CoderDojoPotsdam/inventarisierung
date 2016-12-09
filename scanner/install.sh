#!/bin/bash

sudo apt-get -y install dmidecode hwinfo python3 smartmontools wireless-tools mesa-utils x11-xserver-utils pcmciautils wodim

if ! which scan
then
  (
    here="`dirname \"$0\"`"
    echo
    echo "function scan() {"
    echo "  `realpath \"$here\"`/scan.sh \"\$@\""
    echo "}"
    echo
  ) >> ~/.bashrc
fi
