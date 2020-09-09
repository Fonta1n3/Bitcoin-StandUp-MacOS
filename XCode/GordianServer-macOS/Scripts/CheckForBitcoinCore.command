#!/bin/sh

#  CheckForBitcoinCore.command
#  StandUp
#
#  Created by Peter on 19/11/19.
#  Copyright © 2019 Blockchain Commons, LLC
if [ -d ~/.standup/BitcoinCore ]; then

  ~/.standup/BitcoinCore/$PREFIX/bin/bitcoind -version

else

  PATH="$(command -v bitcoind)"
  $PATH -version

fi

exit 1
