import 'os_gentoo'

# Class service::sasl
#
#  Provides a SASL configuration for the Kolab Server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_postfix
#
# @module root           The root module is required to determine the installed
#                        SASL version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
# @fact version_sasl     The cyrus-sasl version currently installed
#
# @fact kolab_ldap_uri         URI for our LDAP server
# @fact kolab_base_dn          The base DN of the LDAP server
# @fact kolab_bind_dn          The DN for the user with restricted access
# @fact kolab_bind_pw          The password for the user with restricted access
# @fact kolab_postfix_mydomain Our primary mail domain
#
class service::sasl {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { 'cyrus-sasl':
        context => 'service_sasl_sasl',
        package => 'dev-libs/cyrus-sasl',
        use     => 'ldap pam ssl',
        tag     => 'buildhost'
      }
      package { 'cyrus-sasl':
        category => 'dev-libs',
        ensure   => 'installed',
        require  => Gentoo_use_flags['cyrus-sasl'],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'cyrus-sasl':
        ensure  => 'installed';
      }
    }
  }

  $template_sasl = template_version($version_sasl, '2.1.22-r2@:2.1.22-r2,', '2.1.22-r2')

  $ldap_uri = get_var('kolab_ldap_uri', 'ldap://127.0.0.1:389')
  $base_dn = get_var('kolab_base_dn')
  $bind_dn = get_var('kolab_bind_dn')
  $bind_pw = get_var('kolab_bind_pw')
  $mydomain = get_var('kolab_postfix_mydomain')

  file { 
    "${kolab_sasl_authdconffile}":
    content => template("service_sasl/saslauthd.conf_${template_sasl}"),
    mode    => 600,
    require => Package['cyrus-sasl'],
    notify  => Service['saslauthd'];
  }

  service { 'saslauthd':
    ensure    => 'running',
    enable    => true,
    require => Package['cyrus-sasl'];
  }

  case $operatingsystem {
    gentoo: {
      # Configuration for the saslauthd
      file { 
        '/etc/conf.d/saslauthd':
        source => 'puppet:///service_sasl/saslauthd',
        require => Package['cyrus-sasl'],
        notify  => Service['saslauthd'];
      }

      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/saslauthd':
        ensure => '/etc/init.d/saslauthd',
        require  => Package['cyrus-sasl']
      }
    }
  }
}
