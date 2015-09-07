class shorewall::nagios (
  $ensure = $shorewall::ensure
) {
  # validate parameters
  validate_re($ensure, '^(present|absent)$')

  # sudoers
  @nagios::nrpe::sudoer {
    'SHOREWALL_STATUS' :
      ensure => $ensure,
      command => '/sbin/shorewall status' ;

    'SHOREWALL_CONFIGCHECK' :
      ensure => $ensure,
      command => '/sbin/shorewall check' ;

    'SHOREWALL_VERSION' :
      ensure => $ensure,
      command => '/sbin/shorewall version' ;
  }

  # manage nagios checks
  Nagios::Nrpe::Check {
    ensure => $ensure,
    selctx => 'nagios_unconfined_plugin_exec_t',
  }
  @nagios::nrpe::check {
    'check_shorewall_status' :
      source => 'puppet:///modules/shorewall/nagios/check_shorewall_status.sh',
      commands => {
        check_shorewall_status => '',
      },
      require => Nagios::Nrpe::Sudoer['SHOREWALL_STATUS', 'SHOREWALL_VERSION'] ;

    'check_shorewall_configuration' :
      source => 'puppet:///modules/shorewall/nagios/check_shorewall_configuration.sh',
      commands => {
        check_shorewall_configuration => '',
      },
      require => Nagios::Nrpe::Sudoer['SHOREWALL_CONFIGCHECK'] ;

    'check_shorewall_conntrack' :
      source => 'puppet:///modules/shorewall/nagios/check_conntrack.sh',
      commands => {
        check_shorewall_conntrack => '80 90',
      } ;
  }
  Activecheck::Service::Nrpe {
    ensure => $ensure,
    retry_interval_in_seconds => 60,
  }
  @activecheck::service::nrpe {
    'shorewall_status' :
      check_interval_in_seconds => 300,
      max_check_attempts => 1,
      check_command => 'check_shorewall_status' ;

    'shorewall_configuration' :
      check_timeout_in_seconds => 300,
      check_interval_in_seconds => 1800,
      retry_interval_in_seconds => 1800,
      check_command => 'check_shorewall_configuration',
      dependent_service_description => 'shorewall_status' ;

    'shorewall_conntrack' :
      check_command => 'check_shorewall_conntrack' ;
  }
}
