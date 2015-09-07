define shorewall::interface (
  $zone,
  $broadcast = 'detect',
  $options = ['-'],
  $physical = true,
  $ensure = present
) {
  # validate parameters
  validate_string($zone, $broadcast)
  validate_array($options)
  validate_bool($physical)
  validate_re($ensure, '^(present|absent)$')

  file {
    "${shorewall::defaults::interfacesddir}/${name}" :
      ensure => $ensure,
      content => template('shorewall/interfaces.d.erb'),
      notify => Exec[$shorewall::defaults::service_name],
      require => [
        $physical ? { true => Network::Interface[$name], default => [] },
        Shorewall::Zone[$zone]
      ] ;
  }
}
