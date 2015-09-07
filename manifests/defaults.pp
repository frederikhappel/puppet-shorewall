class shorewall::defaults {
  # define variables
  $service_name = 'shorewall'
  $ephemeral_ports = '49152:65535'

  # files and directories
  $cfgdir = '/etc/shorewall'
  $zonesddir = "${cfgdir}/zones.d"
  $interfacesddir = "${cfgdir}/interfaces.d"
  $policyddir = "${cfgdir}/policy.d"
  $rulesddir = "${cfgdir}/rules.d"
  $tunnelsddir = "${cfgdir}/tunnels.d"
  $hostsddir = "${cfgdir}/hosts.d"
  $masqddir = "${cfgdir}/masq.d"

  $cfgfile = "${cfgdir}/shorewall.conf"
  $makefile = "${cfgdir}/Makefile"
}
