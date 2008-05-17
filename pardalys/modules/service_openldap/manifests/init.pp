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
        package => '=net-nds/openldap-2.4.7',
        tag     => 'buildhost'
      }
      gentoo_keywords { openldap:
        context  => 'service_openldap',
        package  => '=net-nds/openldap-2.4.7',
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
        ensure   => 'installed',
      }
    }
  }
}

# Class service::openldap::serve
#  Provides a configuration for the OpenLDAP server
#
# Required parameters 
#
#  * base_dn: The base_dn of the LDAP tree.
#
#  * bind_dn: The master user for the LDAP server
#
#  * bind_pw: The master password for the LDAP server
#
#  * bind_pw_hash: Hashed version of the master password for the LDAP
#    server
#
#  * postfix_mydestination: The destination domains of this Kolab
#    server
#
# Optional parameters 
#
#  * service_openldap_db_config: Sets the path to the DB_CONFIG file
#    if LDAP uses BDB as a backend
#
#  * service_openldap_ruser: The user OpenLDAP will be run with
#
#  * service_openldap_rgroup: The group OpenLDAP will be run with
#
# Templates
#
#  * DB_CONFIG_*: The configuration for the BDB backend
#
# class service::openldap::serve {

#   $template_openldap = template_version($version_openldap, '2.4.7@:2.4.7,', '2.4.7')

#   $sysconfdir = get_var('global_sysconfdir', '/etc')
#   $confdir = get_var('service_openldap_confdir', "$sysconfdir/openldap")
#   $schemadir = get_var('service_openldap_schemadir', "$confdir/schema")
#   $datadir = get_var('service_openldap_datadir', '/var/lib/openldap-data')
#   $pidfile = get_var('service_openldap_pidfile', '/var/run/openldap/slapd.pid')
#   $argsfile = get_var('service_openldap_argsfile', '/var/run/openldap/slapd.args')
#   $db_config = get_var('service_openldap_db_config', '/var/lib/openldap-data/DB_CONFIG')
#   $ruser = get_var('service_openldap_ruser', 'ldap')
#   $cuser = get_var('service_openldap_cuser', 'root')
#   $rgroup = get_var('service_openldap_rgroup', 'ldap')
#   $os = $operatingsystem

#   $postfix_mydestination = split(get_var('postfix_mydestination'), ',')

#       # OpenLDAP configuration
#       file { "$confdir/ldap.conf":
#          content => template("service_openldap/ldap.conf_${template_openldap}"),
#          owner   => "$cuser",
#          group   => "$rgroup",
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$confdir/slapd.conf":
#          content => template("service_openldap/slapd.conf_${template_openldap}"),
#          owner   => "$cuser",
#          group   => "$rgroup",
#          mode    => '640',
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$confdir/slapd.access":
#          content => template("service_openldap/slapd.access_${template_openldap}"),
#          owner   => "$cuser",
#          group   => "$rgroup",
#          mode    => '640',
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$schemadir/puppet.schema":
#          content => template("service_openldap/puppet.schema"),
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$schemadir/horde.schema":
#          content => template("service_openldap/horde.schema"),
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$schemadir/kolab2.schema":
#          content => template("service_openldap/kolab2.schema"),
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$schemadir/rfc2739.schema":
#          content => template("service_openldap/rfc2739.schema"),
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$confdir/rootDSE.ldif":
#          content => template("service_openldap/rootDSE.ldif"),
#          owner   => "$cuser",
#          group   => "$rgroup",
#          notify => Service['slapd'],
#          require => Package['openldap'];
#        "$db_config":
#          content => template("service_openldap/DB_CONFIG_${template_openldap}"),
#          owner   => "$ruser",
#          group   => "$rgroup",
#          notify => Service['slapd'],
#          require => Package['openldap'];
#       }

#       file { '/etc/monit.d/openldap':
#         content => template("service_openldap/monit_ldap"),
#         require => [Package['openldap'], Package['monit']]
#       }

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


#       case $operatingsystem {
#         gentoo:
#         {
#           file { '/etc/conf.d/slapd':
#             content => template("service_openldap/conf.d-slapd_${template_openldap}"),
#             require => Package['openldap']
#           }
#           # Ensure that the service starts with the system
#           file { '/etc/runlevels/default/slapd':
#             ensure => '/etc/init.d/slapd',
#             require  => Package['openldap']
#           }
#         }
#         default:
#         {
#         }
#       }

#       service { 'slapd':
#         ensure    => 'running',
#         enable    => true
#       }
#   }
# }
