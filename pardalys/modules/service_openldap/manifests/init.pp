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

class service::openldap::serve {

  #FIXME!!!
  $template_openldap = template_version($version_openldap, '2.4.7@:2.4.7,', '2.4.7')

  # Make the fact available within the template
  $os = $operatingsystem

#   $postfix_mydestination = split(get_var('postfix_mydestination'), ',')

  # OpenLDAP configuration
  file { 
    "$openldap_confdir/ldap.conf":
    source  => 'puppet://service_openldap/ldap.conf',
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
    "$openldap_confdir/slapd.access":
    content => template("service_openldap/slapd.access_${template_openldap}"),
    owner   => "$openldap_usr",
    group   => "$openldap_grp",
    mode    => '640',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_confdir/rootDSE.ldif":
    source  => 'puppet://service_openldap/rootDSE.ldif',
    owner   => "$openldap_usr",
    group   => "$openldap_grp",
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/puppet.schema":
    source  => 'puppet://service_openldap/puppet.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/horde.schema":
    source  => 'puppet://service_openldap/horde.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/kolab2.schema":
    source  => 'puppet://service_openldap/kolab2.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_schemadir/rfc2739.schema":
    source  => 'puppet://service_openldap/rfc2739.schema',
    notify => Service['slapd'],
    require => Package['openldap'];
    "$openldap_datadir/DB_CONFIG":
    source  => 'puppet://service_openldap/DB_CONFIG',
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
        source  => 'puppet://service_openldap/conf.d-slapd',
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
    ensure    => 'running',
    enable    => true
  }

      file { '/etc/monit.d/openldap':
        content => template("service_openldap/monit_ldap"),
        require => [Package['openldap'], Package['monit']]
      }

      file {
        '/usr/libexec/munin/plugins/slapd_':
          source  => 'puppet:///service_openldap/slapd_',
          mode    => 755;
        ['/etc/munin/plugins/slapd_connections',
         '/etc/munin/plugins/slapd_statistics_bytes',
         '/etc/munin/plugins/slapd_operations',
         '/etc/munin/plugins/slapd_statistics_entries']:

          ensure  => '/usr/libexec/munin/plugins/slapd_',
          require => File['/usr/libexec/munin/plugins/syslog_ng'];
        '/etc/munin/plugin-conf.d/openldap':
          content  => template("service_openldap/munin_ldap.conf");
      }

      file { 
        '/etc/cron.daily/openldap_backup':
        source  => 'puppet:///service_openldap/openldap_backup',
        mode    => 755;
        '/var/backup/data/openldap':
        ensure  => 'directory';
      }

}
