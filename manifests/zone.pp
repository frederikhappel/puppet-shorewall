define shorewall::zone (
  $parents = [],
  $type = 'ipv4',
  $options = ['-'],
  $inoptions = ['-'],
  $outoptions = ['-'],
  $order = 50,
  $ensure = present
) {
  # rename due to errors in template (type is always Puppet::Parser::TemplateWrapper)
  $zonetype = $type

  # validate parameters
  validate_array($parents, $options, $inoptions, $outoptions)
  validate_integer($order, 99, 0)
  validate_re($zonetype, '^(ipv4|ipsec|ipsec4|firewall|bport|bport4|vserver)$')
  validate_re($ensure, '^(present|absent)$')

  # format order prefix
  $order_real = sprintf('%02d', $order)
  file {
    "${shorewall::defaults::zonesddir}/${order_real}-${name}" :
      ensure => $ensure,
      content => template('shorewall/zones.d.erb'),
      notify => Exec[$shorewall::defaults::service_name],
      require => $parents ? { undef => undef, default => Shorewall::Zone[$parents] } ;
  }
}
