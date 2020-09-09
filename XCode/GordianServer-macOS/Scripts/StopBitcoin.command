#!/bin/sh

#  StopBitcoin.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
if [ -d ~/.standup/BitcoinCore ]; then

  ~/.standup/BitcoinCore/$PREFIX/bin/bitcoin-cli -datadir="$DATADIR" stop

else

  PATH="$(command -v bitcoin-cli)"
  $PATH -datadir="$DATADIR" stop

fi

exit 1
