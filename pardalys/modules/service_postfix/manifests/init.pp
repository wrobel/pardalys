import 'os_gentoo'

# Class service::postfix
#
#  Provides a configuration for the postfix MTA
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_postfix
#
# @module root           The root module is required to determine the installed
#                        postfix version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
# @fact version_postfix  The postfix version currently installed
# @fact kolab_bind_addr  The interface postfix should bind to
# @fact kolab_bind_any   Should we bind to any interface?
# @fact kolab_local_addr Our local IP (usually 127.0.0.1)
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

  $sysconfdir         = $os::sysconfdir

  $postfix_confdir    = "${os::sysconfdir}/postfix"
  $postfix_aliasdir   = "${os::sysconfdir}/mail"
  $postfix_aliases    = "${postfix_aliasdir}/aliases"

  $template_postfix = template_version($version_postfix, '2.4.6-r2@:2.4.6-r2,', '2.4.6-r2')

  $bind_addr = get_var('kolab_bind_addr', '0.0.0.0')
  $local_addr = get_var('kolab_local_addr', '127.0.0.1')
  $kolab_bind_any = get_var('kolab_bind_any', 'TRUE')
  case $kolab_bind_any {
    'TRUE': {
      $bind_any = true
    }
    default: {
      $bind_any = false
    }
  }

  $enable_virus_scan = get_var('postfix_enable_virus_scan', true)
  $enable_amavis_fallback = get_var('postfix_enable_amavis_fallback', false)
  $mydomain = get_var('postfix_mydomain')
  $mynetworks = get_var('postfix_mynetworks', '127.0.0.0/8')
  $mydestination = split(get_var('postfix_mydestination'), ',')
  $relayhost = get_var('postfix_relayhost', false)
  $relayport = get_var('postfix_relayport', 25)
  $ldap_uri = get_var('kolab_ldap_uri', 'ldap://127.0.0.1:389')
  $base_dn = get_var('kolab_base_dn', 'dc=example,dc=com')
  $bind_dn_nobody = get_var('kolab_bind_dn_nobody')
  $bind_pw_nobody = get_var('kolab_base_pw_nobody')
  $hostname = get_var('kolab_fqdnhostname')

  file { 
    "${postfix_confdir}/master.cf":
    content => template("service_postfix/master.cf_${template_postfix}"),
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    "${postfix_confdir}/main.cf":
    content => template("service_postfix/main.cf_${template_postfix}"),
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    "${postfix_aliases}":
    source  => 'puppet:///service_postfix/aliases',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_aliases']];
    "${postfix_confdir}/canonical":
    source  => 'puppet:///service_postfix/canonical',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_canonical']];
    "${postfix_confdir}/kolabvirtual":
    source  => 'puppet:///service_postfix/kolabvirtual',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_canonical']];
    "${postfix_confdir}/ldapdistlist":
    content => template("service_postfix/ldapdistlist"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldapdistlist']];
    "${postfix_confdir}/ldaptransport":
    content => template("service_postfix/ldaptransport"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldaptransport']];
    "${postfix_confdir}/ldapvirtual":
    content => template("service_postfix/ldapvirtual"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldapvirtual']];
    "${postfix_confdir}/relocated":
    source  => 'puppet:///service_postfix/relocated',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_relocated']];
    "${postfix_confdir}/transport":
    source  => 'puppet:///service_postfix/transport',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_relocated']];
    "${postfix_confdir}/virtual":
    source  => 'puppet:///service_postfix/virtual',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_virtual']];
    "${postfix_confdir}/header_checks":
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
    cwd  => "${postfix_aliasdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postalias aliases',
    require => Package['postfix'],
    subscribe   => File["${postfix_aliases}"],
    refreshonly => true;
    'map_canonical':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap canonical',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/canonical"],
    refreshonly => true;
    'map_kolabvirtual':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap kolabvirtual',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/kolabvirtual"],
    refreshonly => true;
    'map_ldapdistlist':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldapdistlist',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/ldapdistlist"],
    refreshonly => true;
    'map_ldaptransport':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldaptransport',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/ldaptransport"],
    refreshonly => true;
    'map_ldapvirtual':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldapvirtual',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/ldapvirtual"],
    refreshonly => true;
    'map_relocated':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap relocated',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/relocated"],
    refreshonly => true;
    'map_transport':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap transport',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/transport"],
    refreshonly => true;
    'map_virtual':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap virtual',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/virtual"],
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
