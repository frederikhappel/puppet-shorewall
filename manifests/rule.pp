define shorewall::rule (
  $action,
  $src,
  $dst,
  $proto = '-',
  $dst_port = '-',
  $src_port = '-',
  $dst_orig = '-',
  $rate_limit = '-',
  $user_group = '-',
  $mark = '-',
  $conn_limit = '-',
  $time = '-',
  $order = 50,
  $bidirectional = false,
  $ensure = present
) {
  # validate parameters
  validate_string($action, $rate_limit, $user_group, $mark, $conn_limit, $time)
  if !(is_array($src) or is_string($src)) {
    fail('$src needs to be of type String or Array')
  } elsif !(is_array($dst) or is_string($dst)) {
    fail('$dst needs to be of type String or Array')
  } elsif !(is_array($proto) or is_string($proto) or is_integer($proto)) {
    fail('$proto needs to be of type String, Integer or Array')
  } elsif !(is_array($dst_port) or is_string($dst_port) or is_integer($dst_port)) {
    fail('$dst_port needs to be of type String, Integer or Array')
  } elsif !(is_array($src_port) or is_string($src_port) or is_integer($src_port)) {
    fail('$src_port needs to be of type String, Integer or Array')
  } elsif !(is_array($dst_orig) or is_string($dst_orig) or is_integer($dst_orig)) {
    fail('$dst_orig needs to be of type String, Integer or Array')
  }
  validate_integer($order, 99, 0)
  validate_bool($bidirectional)
  validate_re($ensure, '^(present|absent)$')

  # format order prefix
  $order_real = sprintf('%02d', $order)
  file {
    "${shorewall::defaults::rulesddir}/${order_real}-${name}" :
      ensure => $ensure,
      owner => 'root',
      group => 'root',
      mode => '0644',
      content => template('shorewall/rules.d.erb'),
      notify => Exec[$shorewall::defaults::service_name] ;
  }
}
