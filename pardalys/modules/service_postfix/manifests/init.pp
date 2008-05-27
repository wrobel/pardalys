import 'os_gentoo'

# Class service::postfix
#  Provides a configuration for the postfix MTA
#
# Required parameters 
#
#  *  : 
#
# Optional parameters 
#
#  *  : 
#
# Templates
#
#  * templates/ : 
#
# Files
#
#  * files/ : 
#
# Plugins
#
#  * plugins/ : 
#
class service::postfix {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { 'postfix':
        context => 'service_postfix_postfix',
        package => 'mail-mta/postfix',
        use     => 'ldap sasl ssl mailwrapper',
        tag     => 'buildhost'
      }
      package { 'postfix':
        category => 'mail-mta',
        ensure   => 'installed',
        require  => Gentoo_use_flags['postfix'],
        tag      => 'buildhost';
      }
      gentoo_use_flags { 'ssmtp':
        context => 'service_postfix_ssmtp',
        package => 'mail-mta/ssmtp',
        use     => 'mailwrapper',
        tag     => 'buildhost'
      }
      package { 'ssmtp':
        category => 'mail-mta',
        ensure   => 'installed',
        require  => Gentoo_use_flags['ssmtp'],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'postfix':
        ensure  => 'installed';
      }
    }
  }
  
  $template_postfix = template_version($version_postfix, '2.4.6-r2@:2.4.6-r2,', '2.4.6-r2')

  $bind_addr = get_var('postfix_bind_addr', '0.0.0.0')
  $local_addr = get_var('postfix_local_addr', '127.0.0.1')
  $enable_virus_scan = get_var('postfix_enable_virus_scan', true)
  $bind_any = get_var('postfix_bind_any', true)
  $mydomain = get_var('postfix_mydomain')
  $mynetworks = get_var('postfix_mynetworks', '127.0.0.0/8')
  $mydestination = split(get_var('postfix_mydestination'), ',')
  $relayhost = get_var('postfix_relayhost', false)
  $relayport = get_var('postfix_relayport', 25)
  $ldap_uri = get_var('kolab_ldap_uri', 'ldap://127.0.0.1')

  file { 
    '/etc/postfix/master.cf':
    content => template("service_postfix/master.cf_${template_postfix}"),
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    '/etc/postfix/main.cf':
    content => template("service_postfix/main.cf_${template_postfix}"),
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    '/etc/mail/aliases':
    source  => 'puppet:///service_postfix/aliases',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_aliases']];
    '/etc/postfix/canonical':
    source  => 'puppet:///service_postfix/canonical',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_canonical']];
    '/etc/postfix/kolabvirtual':
    source  => 'puppet:///service_postfix/kolabvirtual',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_canonical']];
    '/etc/postfix/ldapdistlist':
    content => template("service_postfix/ldapdistlist"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldapdistlist']];
    '/etc/postfix/ldaptransport':
    content => template("service_postfix/ldaptransport"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldaptransport']];
    '/etc/postfix/ldapvirtual':
    content => template("service_postfix/ldapvirtual"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldapvirtual']];
    '/etc/postfix/relocated':
    source  => 'puppet:///service_postfix/relocated',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_relocated']];
    '/etc/postfix/transport':
    source  => 'puppet:///service_postfix/transport',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_relocated']];
    '/etc/postfix/virtual':
    source  => 'puppet:///service_postfix/virtual',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_virtual']];
    '/etc/postfix/header_checks':
    source  => 'puppet:///service_postfix/header_checks',
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
#
#    '/etc/monit.d/postfix':
#    source  => 'puppet:///service_cron/monit_postfix';
  }

  exec {
    'map_aliases':
    cwd  => '/etc/mail',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postalias aliases',
    require => Package['postfix'],
    subscribe   => File['/etc/mail/aliases'],
    refreshonly => true;
    'map_canonical':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap canonical',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/canonical'],
    refreshonly => true;
    'map_kolabvirtual':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap kolabvirtual',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/kolabvirtual'],
    refreshonly => true;
    'map_ldapdistlist':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldapdistlist',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/ldapdistlist'],
    refreshonly => true;
    'map_ldaptransport':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldaptransport',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/ldaptransport'],
    refreshonly => true;
    'map_ldapvirtual':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldapvirtual',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/ldapvirtual'],
    refreshonly => true;
    'map_relocated':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap relocated',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/relocated'],
    refreshonly => true;
    'map_transport':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap transport',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/transport'],
    refreshonly => true;
    'map_virtual':
    cwd  => '/etc/postfix',
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap virtual',
    require => Package['postfix'],
    subscribe   => File['/etc/postfix/virtual'],
    refreshonly => true;
  }

  service { 'postfix':
    ensure    => 'running',
    enable    => true,
    require => Package['postfix'];
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/postfix':
        ensure => '/etc/init.d/postfix',
        require  => Package['postfix']
      }
    }
  }
}
