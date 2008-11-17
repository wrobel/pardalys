import 'root'
import 'os_gentoo'

# Class service::apache
#
#  Provides the Apache configuration for the Kolab Server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_apache
#
# @module root           The root module is required to determine the installed
#                        Apache version.
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
class service::apache {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { 'php-apache':
        context => 'service_apache_php',
        package => 'dev-lang/php',
        use     => 'kolab imap ldap nls session xml apache2 ctype ftp gd json sqlite tokenizer spl pcre reflection',
        tag     => 'buildhost'
      }
      gentoo_use_flags { 'apr-util':
        context => 'service_apache_apr-util',
        package => 'dev-libs/apr-util',
        use     => 'ldap ssl',
        tag     => 'buildhost'
      }
      package { 'apr-util':
        category => 'dev-libs',
        ensure   => 'installed',
        require  => Gentoo_use_flags['apr-util'],
        tag      => 'buildhost';
      }
      # FIXME: Remove the "mod_python" python once we serve no python
      # anymore
      package { 'mod_python':
        category => 'www-apache',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      gentoo_use_flags { 'apache':
        context => 'service_apache_apache',
        package => 'www-servers/apache',
        use     => 'ldap ssl',
        tag     => 'buildhost'
      }
      package { 'apache':
        category => 'www-servers',
        ensure   => 'installed',
        require  => [Gentoo_use_flags['apache'], Line['make_conf_puppet_apache']],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'apache':
        ensure  => 'installed';
      }
    }
  }

  $sysconfdir         = $os::sysconfdir

  $apache_confdir    = "${os::sysconfdir}/apache2"

  $template_apache = template_version($version_apache, '2.2.9@:2.2.9,', '2.2.9')

  $apache_start_opts = get_var('apache_start_opts', '')
  $apache_run_service = get_var('run_services', true)

  @line {'make_conf_puppet_apache':
    file => '/etc/portage/make.conf.puppet',
    line => 'APACHE2_MODULES="actions alias auth_basic authn_alias authn_anon authn_dbm authn_default authn_file authz_dbm authz_default authz_groupfile authz_host authz_owner authz_user autoindex cache dav dav_fs dav_lock deflate dir disk_cache env expires ext_filter file_cache filter headers include info log_config logio mem_cache mime mime_magic negotiation rewrite setenvif speling status unique_id userdir usertrack vhost_alias"',
    tag => 'buildhost'
  }

  if $apache_run_service {
    service { 'apache2':
      ensure    => 'running',
      enable    => true,
      require => Package['apache'];
    }
  }

  if defined(File['/etc/monit.d']) {
    file { 
      '/etc/monit.d/apache2':
      source => 'puppet:///service_apache/monit_apache';
    }
  }

  file { 
    '/etc/apache2/vhosts.d/00_default_ssl_vhost.conf':
    source => 'puppet:///service_apache/00_default_ssl_vhost.conf';
  }

  case $operatingsystem {
    gentoo: {
      # Configuration for the apache
      file { 
        '/etc/conf.d/apache2':
        content => template('service_apache/apache2'),
        require => Package['apache'],
        notify  => Service['apache2'];
      }

      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/apache2':
        ensure => '/etc/init.d/apache2',
        require  => Package['apache']
      }
    }
  }
}
