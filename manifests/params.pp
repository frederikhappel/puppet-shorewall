class shorewall::params (
  $zone_int = 'loc',
  $zone_ext = 'loc',
  $params_default = undef,
  $params_custom = undef,
  $params_template = undef,
  $ensure = $shorewall::ensure
) inherits shorewall::defaults {
  # validate parameters
  validate_string($zone_int, $zone_ext, $params_template)
  if !is_array($params_default) and !is_string($params_default) {
    fail('$params_default needs to be of type String or Array')
  } elsif !is_array($params_custom) and !is_string($params_custom) {
    fail('$params_custom needs to be of type String or Array')
  }
  validate_re($ensure, '^(present|absent)$')

  # manage configuration files
  file {
    "${cfgdir}/params" :
      ensure => $ensure,
      content => template('shorewall/params.erb'),
      notify => $ensure ? { 'present' => Exec[$service_name], default => [] } ;
  }
}
