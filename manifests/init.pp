class shorewall (
  $all2all_action = 'REJECT',
  $all2all_logger = 'info',
  $clampmss = 'No',
  $ip_forwarding = 'Off',
  $logprefix = 'FW',
  $fastaccept = false,
  $implicit_continue = false,
  $logmartians = true,
  $routefilter = false,
  $blacklist = ['NEW', 'INVALID', 'UNTRACKED'],
  $conntrack_max = 65535,
  $version = present,
  $ensure = present
) inherits shorewall::defaults {
  # validate parameters
  validate_string($logprefix, $version)
  validate_integer($conntrack_max)
  validate_re($all2all_logger, '^(-|debug|info|notice|warning|warn|err|error|crit|alert|emerg|panic)$')
  validate_re($all2all_action, '^(REJECT|ACCEPT|DROP)$')
  validate_bool($fastaccept, $implicit_continue, $logmartians, $routefilter)
  validate_array($blacklist)
  if is_integer($clampmss) {
    validate_integer($clampmss)
  } else {
    validate_re($clampmss, '^(Yes|No)$')
  }
  validate_re($ip_forwarding, '^(On|Off|Keep)$')
  validate_re($ensure, '^(present|absent)$')

  # include classes
  class {
    'shorewall::nagios' :
      ensure => $ensure ;
  }

  # package management
  # TODO: yum repo ['shorewall', 'fedora-epel']
  yum::versionedpackage {
    ['shorewall', 'shorewall-core'] : # repo shorewall
      ensure => $ensure,
      version => $version ;
  }

  # configure shorewall
  case $ensure {
    present: {
      # Kernel sysctl configuration
      sysctl::value {
        'net.netfilter.nf_conntrack_max' :
          value => $conntrack_max,
          require => Package['shorewall'] ;

        'net.ipv4.ip_forward' :
          ensure => $ip_forwarding ? { 'Keep' => absent, default => present },
          value => $ip_forwarding ? { 'On' => 1, default => 0 },
          require => Package['shorewall'] ;
      }

      # default file permissions
      File {
        owner => 0,
        group => 0,
        notify => Exec[$service_name],
        require => Package['shorewall'],
      }
      file {
        [$cfgdir, $zonesddir, $interfacesddir, $policyddir, $rulesddir,
         $tunnelsddir, $hostsddir, $masqddir] :
          ensure => directory,
          purge => true,
          recurse => true,
          mode => '0644',
          notify => undef ;

        $makefile :
          source => 'puppet:///modules/shorewall/Makefile',
          notify => undef ;

        $cfgfile :
          content => template('shorewall/shorewall.conf.erb') ;

        "${cfgdir}/zones" :
          content => template('shorewall/zones.erb') ;

        "${cfgdir}/interfaces" :
          content => template('shorewall/interfaces.erb') ;

        "${cfgdir}/policy" :
          content => template('shorewall/policy.erb') ;

        "${cfgdir}/rules" :
          content => template('shorewall/rules.erb') ;

        "${cfgdir}/tunnels" :
          content => template('shorewall/tunnels.erb') ;

        "${cfgdir}/hosts" :
          content => template('shorewall/hosts.erb') ;

        "${cfgdir}/masq" :
          content => template('shorewall/masq.erb') ;
      }

      # create catch all policy
      shorewall::policy {
        'all2all' :
          src => 'all',
          dst => 'all',
          action => $all2all_action,
          logger => $all2all_logger,
          order => 99 ;
      }

      # add selinux module
      selinux::module {
        'shorewall_script_exec' :
          ensure => $::operatingsystemmajrelease ? { 5 => absent, default => present },
          source => 'puppet:///modules/shorewall/selinux_shorewall_script_exec.te',
          notify => Exec[$service_name] ;
      }

      # realize all virtual shorewall resources
      Shorewall::Zone <||>
      Shorewall::Interface <||>
      Shorewall::Tunnel <||>
      Shorewall::Policy <||>
      Shorewall::Rule <||>
      Shorewall::Hosts <||>
      Shorewall::Masq <||>

      # define service
      service {
        $service_name :
          ensure => running,
          enable => true,
          start => '/sbin/shorewall start',
          stop => '/sbin/shorewall stop',
          restart => '/sbin/shorewall restart',
          status => '/sbin/shorewall status',
          subscribe => Package['shorewall'] ;
      }
      exec {
        $service_name :
          command => '/sbin/shorewall restart',
          refreshonly => true,
          tries => 10,
          require => Service[$service_name] ;
      }
    }

    absent: {
      # restart shorewall
      exec {
        'shorewallRemove' :
          command => 'service iptables stop',
          unless => 'test $(iptables -L | grep -i "chain.*accept" | wc -l) -eq 3',
          environment => 'LANG=C' ;
      }

      # delete config file
      file {
        $cfgdir :
          ensure => absent,
          recurse => true,
          force => true ;
      }

      # remove selinux module
      selinux::module {
        'shorewallAllowScriptExec' :
          ensure => absent,
          source => 'puppet:///modules/shorewall/selinux_shorewallAllowScriptExec.te' ;
      }
    }
  }
}
