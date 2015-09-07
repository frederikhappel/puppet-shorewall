#!/bin/bash
# This file is managed by puppet! Do not change!
#
# Author:  Frederik Happel <mail@frederikhappel.de>
# Date:    08/19/2014
# Purpose: Nagios plugin (script) to check shorewall configuration status.
#
LANG=C

md5_file="/tmp/shorewall.md5"

# source nagios utils.sh
dir_plugins=$(dirname $0)
if ! . ${dir_plugins}/utils.sh ; then
  echo "UNKNOWN - missing nagios utils.sh"
  exit 3
fi

# check md5 sum
if ! md5sum -c ${md5_file} &>/dev/null ; then
  tmp_file=$(mktemp)
  find /etc/shorewall -type f -print0 | xargs -0 md5sum 1>> ${tmp_file}
  if ! error=$(sudo /sbin/shorewall check | grep -i error) ; then
    mv ${tmp_file} ${md5_file} &>/dev/null
    echo "OK - Validated configuration"
    exit ${STATE_OK}
  fi
  rm -f ${tmp_file} &>/dev/null
else
  echo "OK - Configuration unchanged and valid"
  exit ${STATE_OK}
fi

echo -e "CRITICAL - Configuration invalid\n${error}"
exit ${STATE_CRITICAL}
