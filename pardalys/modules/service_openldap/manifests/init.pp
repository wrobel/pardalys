import 'os_gentoo'

# Class service::openldap
#
#  Provides the package installation for the OpenLDAP server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_openldap
#
# @fact operatingsystem Allows to choose the correct package name
#                       depending on the operating system
# @fact keyword         The keyword for the system which is used to
#                       select unstable packages
#
class service::openldap {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_unmask { openldap:
        context => 'service_openldap',
        package => '=net-nds/openldap-2.4.16',
        tag     => 'buildhost'
      }
      gentoo_keywords { openldap:
        context  => 'service_openldap',
        package  => '=net-nds/openldap-2.4.16',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_use_flags { openldap:
        context => 'service_openldap',
        package => 'net-nds/openldap',
        use     => 'berkdb crypt overlays perl ssl syslog -sasl',
        tag     => 'buildhost'
      }
      package { openldap:
        category => 'net-nds',
        ensure   => 'latest',
        require  =>  [ Gentoo_unmask['openldap'],
                       Gentoo_keywords['openldap'],
                       Gentoo_use_flags['openldap'] ],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { openldap:
        ensure   => 'latest',
      }
    }
  }
}

# Class service::openldap::serve
#
#  Provides a configuration for the OpenLDAP server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_openldap
#
# @fact operatingsystem    Allows to select additional tasks based on the
#                          distribution
# @fact version_openldap   The openldap version currently installed
# @fact openldap_configdir The main openldap configuration directory
# @fact openldap_schemadir Repository of schema files
# @fact openldap_datadir   Storage location for the server data
# @fact openldap_usr       The user owning the OpenLDAP configuration files
# @fact openldap_rusr      The user running the slapd server process
# @fact openldap_grp       The group running the slapd server process
#                          (also needs read access to the configuration files)
class service::openldap::serve {

  $sysconfdir         = $os::sysconfdir

  $openldap_confdir   = $kolab_ldapserver_confdir
  $openldap_schemadir = $kolab_ldapserver_schemadir
  $openldap_datadir   = $kolab_ldapserver_dir
  $openldap_pidfile   = $kolab_ldapserver_pidfile
  $openldap_argsfile  = $kolab_ldapserver_argsfile
  $openldap_usr       = $kolab_ldapserver_usr
  $openldap_rusr      = $kolab_ldapserver_rusr
  $openldap_grp       = $kolab_ldapserver_rgrp

  user {
    "$openldap_rusr":
      ensure     => 'present',
      gid        => "$openldap_grp",
      groups     => ["${kolab::service::kolab::kolab_grp}"],
      provider => 'useradd',
      membership => 'minimum';

  }

  $openldap_master    = get_var('openldap_master', true)
  $openldap_slave     = get_var('openldap_slave', '')
  $ca_cert            = get_var('ca_cert', false)
  $run_services = get_var('run_services', 'running')

  $ssl_cert_path  = $tool::openssl::ssl_cert_path
  $ssl_key_path   = $tool::openssl::ssl_key_path

  $template_openldap = template_version($version_openldap, '2.4.7@2.4.11@2.4.16@:2.4.7,', '2.4.7')

  # Make the fact available within the template
  $os = $operatingsystem

#   $postfix_mydestination = split(get_var('postfix_mydestination'), ',')

  # OpenLDAP configuration
  file { 
    "$openldap_confdir/ldap.conf":
    content => template("service_openldap/ldap.conf"),
    owner   => "$openldap_usr",
    group   => "$openldap_grp",
    require => Package['openldap'];
    "$openldap_confdir/slapd.conf":
    content => template("service_openldap/slapd.conf_${template_openldap}"),
    owner   => "$openldap_usr",
    group   => "$openldap_grp",
    mode    => '640',
    notify => Service['slapd'],
    require => Package['openldap'];
#     "$openldap_confdir/slapd.access":
#     content => template("service_openldap/slapd.access_${template_openldap}"),
#     owner   => "$openldap_usr",
#     group   => "$openldap_grp",
#     mode    => '640',
#     notify => Service['slapd'],
#     require => Package['openldap'];
    "$openldap_confdir/rootDSE.ldif":
    source  => 'puppet:///service_openldap/rootDSE.ldif',
    owner   => "$openldap_usr",
    group   => "$openldap_grp",
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/puppet.schema":
    source  => 'puppet:///service_openldap/puppet.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/horde.schema":
    source  => 'puppet:///service_openldap/horde.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/kolab2.schema":
    source  => 'puppet:///service_openldap/kolab2.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/rfc2739.schema":
    source  => 'puppet:///service_openldap/rfc2739.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_datadir/DB_CONFIG":
    source  => 'puppet:///service_openldap/DB_CONFIG',
    owner   => "$openldap_rusr",
    group   => "$openldap_grp",
    notify  => Service['slapd'],
    require => Package['openldap'];
  }

  case $operatingsystem {
    gentoo:
    {
      file {
        '/etc/conf.d/slapd':
        source  => 'puppet:///service_openldap/conf.d-slapd',
        require => Package['openldap']
      }
      # Ensure that the service starts with the system
      file { 
        '/etc/runlevels/default/slapd':
        ensure => '/etc/init.d/slapd',
        require  => Package['openldap']
      }
    }
    default:
    {
    }
  }

  service {
    'slapd':
    ensure    => $run_services,
    enable    => true
  }

  if $kolab_bootstrap {
    kolabldap { 
      "$kolab_ldap_uri":
      basedn  => "$kolab_base_dn",
      binddn  => "$kolab_bind_dn",
      passwd  => "$kolab_bind_pw",
      ensure  => 'present',
      require => Service['slapd']
    }
  }

  if defined(File['/etc/monit.d']) {
    file {
      '/etc/monit.d/openldap':
      content => template("service_openldap/monit_ldap"),
      require => Package['openldap']
    }
  }

#       file {
#         '/usr/libexec/munin/plugins/slapd_':
#           source  => 'puppet:///service_openldap/slapd_',
#           mode    => 755;
#         ['/etc/munin/plugins/slapd_connections',
#          '/etc/munin/plugins/slapd_statistics_bytes',
#          '/etc/munin/plugins/slapd_operations',
#          '/etc/munin/plugins/slapd_statistics_entries']:

#           ensure  => '/usr/libexec/munin/plugins/slapd_',
#           require => File['/usr/libexec/munin/plugins/syslog_ng'];
#         '/etc/munin/plugin-conf.d/openldap':
#           content  => template("service_openldap/munin_ldap.conf");
#       }

#       file { 
#         '/etc/cron.daily/openldap_backup':
#         source  => 'puppet:///service_openldap/openldap_backup',
#         mode    => 755;
#         '/var/backup/data/openldap':
#         ensure  => 'directory';
#       }

}
