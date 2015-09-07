class shorewall::rules (
  $rules_custom = undef,
  $rules_default = undef,
  $rules_template = undef,
  $ensure = $shorewall::ensure
) inherits shorewall::defaults {
  # validate parameters
  validate_string($rules_custom, $rules_default, $rules_template)
  validate_re($ensure, '^(present|absent)$')

  # manage configuration files
  File {
    notify => $ensure ? { 'present' => Exec[$service_name], default => [] }
  }
  file {
    "${rulesddir}/00-custom" :
      ensure => $rules_custom ? { undef => absent, default => $ensure },
      content => $rules_custom ;

    "${rulesddir}/98-default" :
      ensure => $rules_default ? { undef => absent, default => $ensure },
      content => $rules_default ;

    "${rulesddir}/99-default" :
      ensure => $rules_template ? { undef => absent, default => $ensure },
      content => template($rules_template) ;
  }
}
