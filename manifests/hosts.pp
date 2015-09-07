define shorewall::hosts (
  $iface,
  $hosts,
  $options = ['-'],
  $order = 50,
  $ensure = present
) {
  # validate parameters
  validate_string($iface)
  validate_array($hosts, $options)
  validate_integer($order, 99, 0)
  validate_re($ensure, '^(present|absent)$')

  # format order prefix
  $order_real = sprintf('%02d', $order)
  file {
    "${shorewall::defaults::hostsddir}/${order_real}-${name}" :
      ensure => $ensure,
      content => template('shorewall/hosts.d.erb'),
      notify => Exec[$shorewall::defaults::service_name],
      require => Shorewall::Zone[$name] ;
  }
}
