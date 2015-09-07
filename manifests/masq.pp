define shorewall::masq (
  $dst,
  $src = '0.0.0.0/0',
  $snat_address = '-',
  $order = 50,
  $ensure = present
) {
  # validate parameters
  validate_string($dst, $snat_address)
  if !(is_array($src) or is_string($src)) {
    fail('$src needs to be of type String or Array')
  }
  validate_integer($order, 99, 0)
  validate_re($ensure, '^(present|absent)$')

  # format order prefix
  $order_real = sprintf('%02d', $order)
  file {
    "${shorewall::defaults::masqddir}/${order_real}-${name}" :
      ensure => $ensure,
      owner => 'root',
      group => 'root',
      mode => '0644',
      content => template('shorewall/masq.d.erb'),
      notify => Exec[$shorewall::defaults::service_name] ;
  }
}
