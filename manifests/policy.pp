define shorewall::policy (
  $src,
  $dst,
  $action,
  $logger = '-',
  $order = 50,
  $bidirectional = false,
  $ensure = present
) {
  # validate parameters
  if !is_array($src) and !is_string($src) {
    fail('$src needs to be of type String or Array')
  } elsif !is_array($dst) and !is_string($dst) {
    fail('$dst needs to be of type String or Array')
  }
  validate_re($logger, '^(-|debug|info|notice|warning|warn|err|error|crit|alert|emerg|panic)$')
  validate_re($action, '^(REJECT|ACCEPT|DROP|CONTINUE|QUEUE|NFQUEUE[0-9]*|NONE)$')
  validate_integer($order, 99, 0)
  validate_bool($bidirectional)
  validate_re($ensure, '^(present|absent)$')

  # format order prefix
  $order_real = sprintf('%02d', $order)
  file {
    "${shorewall::defaults::policyddir}/${order_real}-${name}" :
      ensure => $ensure,
      content => template('shorewall/policy.d.erb'),
      notify => Exec[$shorewall::defaults::service_name] ;
  }
}
