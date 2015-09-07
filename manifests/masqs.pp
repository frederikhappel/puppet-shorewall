class shorewall::masqs (
  $rules = undef,
  $ensure = $shorewall::ensure
) inherits shorewall::defaults {
  # validate parameters
  validate_string($rules)
  validate_re($ensure, '^(present|absent)$')

  # manage configuration files
  file {
    "${masqddir}/00-custom" :
      ensure => $rules ? { undef => absent, default => $ensure },
      content => $rules,
      notify => $ensure ? { 'present' => Exec[$service_name], default => [] }
  }
}
