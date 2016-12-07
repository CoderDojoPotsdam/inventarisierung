#!/bin/bash

sudo apt-get -y install dmidecode hwinfo python3 smartmontools

if ! which scan
then
  (
    echo
    echo "function scan() {"
    echo "  `dirname \"$0\"`/scan.sh"
    echo "}"
    echo
  ) >> ~/.bashrc
fi
