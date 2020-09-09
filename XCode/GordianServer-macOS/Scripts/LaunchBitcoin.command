#!/bin/sh

#  LaunchBitcoin.command
#  StandUp
#
#  Created by Peter on 05/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
if [ -d ~/.standup/BitcoinCore ]; then

  ~/.standup/BitcoinCore/$PREFIX/bin/bitcoind -datadir="$DATADIR" -daemon

else

  PATH="$(command -v bitcoind)"
  $PATH -datadir="$DATADIR" -daemon

fi
exit 1
