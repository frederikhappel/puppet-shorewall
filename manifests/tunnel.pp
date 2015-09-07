define shorewall::tunnel (
  $gateways,
  $gateway_zones = [],
  $tunnel_type = 'ipsec',
  $parent_zones = ['net'],
  $order = 50,
  $ensure = present
) {
  # validate parameters
  validate_array($gateways, $gateway_zones, $parent_zones)
  validate_re($tunnel_type, '^(6to4|6in4|ipsec(|:(noah|ah))|ipsecnat|ipip|gre|l2tp|pptpclient|pptpserver|(openvpn|openvpnclient|openvpnserver)(|:(tcp|udp))(|:[0-9][0-9]*)|generic:(tcp|udp)(|:[0-9][0-9]*))$')
  validate_integer($order, 99, 0)
  validate_re($ensure, '^(present|absent)$')

  # format order prefix
  $order_real = sprintf('%02d', $order)
  file {
    "${shorewall::defaults::tunnelsddir}/${order_real}-${name}" :
      ensure => $ensure,
      content => template('shorewall/tunnels.d.erb'),
      notify => Exec[$shorewall::defaults::service_name],
      require => Shorewall::Zone[$gateway_zones, $parent_zones] ;
  }
}
