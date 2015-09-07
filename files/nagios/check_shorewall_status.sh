#!/bin/bash
# This file is managed by puppet! Do not change!

# defaults
LANG=C
dir_plugins=$(dirname $0)

# source nagios utils.sh
if ! . ${dir_plugins}/utils.sh ; then
  echo "UNKNOWN - missing nagios utils.sh"
  exit 3
fi

version=$(sudo /sbin/shorewall version)
if sudo /sbin/shorewall status | grep -i 'Shorewall is running' >/dev/null 2>&1 ; then
  echo "OK - Shorewall is running (v${version})"
  exit ${STATE_OK}
fi

echo -e "CRITICAL - Shorewall is not running (v${version})"
exit ${STATE_CRITICAL}
