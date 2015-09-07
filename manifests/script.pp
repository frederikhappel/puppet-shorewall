define shorewall::script (
  $content,
  $ensure = present
) {
  # validate parameters
  if !is_array($content) and !is_string($content) {
    fail('$content needs to be of type String or Array')
  }
  validate_re($ensure, '^(present|absent)$')

  file {
    "${shorewall::defaults::cfgdir}/${name}" :
      ensure => $content ? { undef => absent, default => $ensure },
      content => template('shorewall/script.erb'),
      notify => Exec[$shorewall::defaults::service_name] ;
  }
}
