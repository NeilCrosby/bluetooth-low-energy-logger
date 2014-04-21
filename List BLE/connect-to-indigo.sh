#!/bin/sh

#  connect-to-indigo.sh
#  List BLE
#
#  Created by Neil Crosby on 20/04/2014.
#  Copyright (c) 2014 Neil Crosby. All rights reserved.

cd "$( dirname "${BASH_SOURCE[0]}" )"

sed "s/VAR-NAME/ble-$1/g" indigo-commands > /tmp/indigo-commands

/Library/Application\ Support/Perceptive\ Automation/Indigo\ 6/IndigoPluginHost.app/Contents/MacOS/IndigoPluginHost -x /tmp/indigo-commands