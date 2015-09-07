#!/bin/bash
# Check de nagios para monitorizar el numero de conexiones establecidas 
# nablas@gmail.com
#
# Version history
#
# 0.1:  First release
# 0.2:  The path /proc/sys/net/ipv4/netfilter/ip_conntrack_count may be 
# differtent in each distribution, so now the script search for it.
#

# get parameters
PERCENT_WARN=${1:-75}
PERCENT_CRIT=${2:-90}

# variables
COUNT_FILE=$(find /proc/sys -name *conntrack_count | head -n 1)
MAX_FILE=$(find /proc/sys -name *conntrack_max | head -n 1)

# sanity checks
if [ $# != 2 ]; then
  echo "Syntax: check_conntrack <warn percent> <crit percent>"
  echo "Example: check_conntrack 75 90"
  exit -1
elif [ -z ${MAX_FILE} ] || [ -z ${COUNT_FILE} ] ; then
  echo "ERROR - No files found (SELinux Problem?)"
  exit -1
fi

# calculation
COUNT=$(cat ${COUNT_FILE} | head -n 1)
MAX=$(cat ${MAX_FILE} | head -n 1)
WARN=$(expr ${MAX} \* ${PERCENT_WARN} \/ 100)
CRIT=$(expr ${MAX} \* ${PERCENT_CRIT} \/ 100)
perfdata="conntrack=${COUNT};${WARN};${CRIT};${MAX}"

# evaluation
if [ ${COUNT} -lt ${CRIT} ] && [ ${COUNT} -ge ${WARN} ] ; then
  echo "WARNING - ${COUNT} connections | ${perfdata}"
  exit 1
elif [ ${COUNT} -ge ${CRIT} ]; then
  echo "CRITICAL - ${COUNT} connections | ${perfdata}"
  exit 2
fi

echo "OK - ${COUNT} connections | ${perfdata}"
exit 0
