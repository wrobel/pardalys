import 'os_gentoo'

# Class service::horde
#
#  Provides the Horde configuration for the Kolab Server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_horde
#
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
#
class service::horde {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { 'horde-webmail':
        context => 'service_horde_webmail',
        package => '=www-apps/horde-webmail-1.1.1',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_use_flags { 'horde-webmail':
        context => 'service_horde_webmail',
        package => 'www-apps/horde-webmail',
        use     => 'kolab ldap',
        tag     => 'buildhost'
      }
      package { 'horde-webmail':
        category => 'www-apps',
        ensure   => 'installed',
        require  => [Gentoo_use_flags['horde-webmail'], Gentoo_keywords['horde-webmail']],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'horde-webmail':
        ensure  => 'installed';
      }
    }
  }

  $template_horde_webmail = template_version($version_horde_webmail, '1.1.1(1.1.1)@:1.1.1,', '1.1.1')

  $sysconfdir  = $os::sysconfdir

  $horde_vhost = get_var('horde_vhost', 'localhost')
  $horde_vhost_path = get_var('horde_vhost_path', '/')

  $horde_webroot = "/var/www/${horde_vhost}/htdocs${horde_vhost_path}"

  $sysadmin = get_var('sysadmin')
  $horde_maildomain = get_var('horde_maildomain', get_var('domainname'))

  $ldap_host    = get_var('pardalys_ldapserver', 'localhost')
  $ldap_base_dn = get_var('base_dn')
  $ldap_bind_dn = get_var('bind_dn_nobody')
  $ldap_bind_pw = get_var('bind_pw_nobody')

  $imap_host    = get_var('imap_host', 'localhost')

  $apache_usr = 'apache'
  $apache_grp = 'apache'

  
  exec { horde_webapp:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "webapp-config -I -h $horde_vhost -d $horde_vhost_path horde-webmail $template_horde_webmail",
    unless => "test -e ${horde_webroot}/index.php",
    require => Package['horde-webmail'];
  }

  file {
    "${horde_webroot}/.htaccess":
    content  => template('service_horde/htaccess_horde'),
    require => Exec['horde_webapp'];
    "${horde_webroot}/config/conf.php":
    source  => "puppet:///service_horde/horde_conf_php_$template_horde_webmail",
    owner   => 'root',
    group   => "$apache_grp",
    mode    => 664,
    require => Exec['horde_webapp'];
    "${horde_webroot}/config/kolab.php":
    content => template("service_horde/horde_kolab.php_$template_horde_webmail"),
    owner   => 'root',
    group   => "$apache_grp",
    mode    => 664,
    require => Exec['horde_webapp'];
    "${horde_webroot}/storage":
    ensure  => 'directory',
    require => Exec['horde_webapp'];
    "${horde_webroot}/storage/horde.db":
    owner   => 'root',
    group   => "$apache_grp",
    mode    => 664,
    require => File["${horde_webroot}/storage"];
    "${horde_webroot}/storage/.htaccess":
    source  => "puppet:///service_horde/htaccess_deny",
    require => File["${horde_webroot}/storage"];
    "${horde_webroot}/tmp":
    ensure  => 'directory',
    owner   => "$apache_usr",
    group   => "$apache_grp",
    mode    => 775,
    require => Exec['horde_webapp'];
    "${horde_webroot}/tmp/.htaccess":
    source  => "puppet:///service_horde/htaccess_deny",
    require => File["${horde_webroot}/tmp"];
    "${horde_webroot}/log":
    ensure  => 'directory',
    owner   => "$apache_usr",
    group   => "$apache_grp",
    mode    => 775,
    require => Exec['horde_webapp'];
    "${horde_webroot}/log/.htaccess":
    source  => "puppet:///service_horde/htaccess_deny",
    require => File["${horde_webroot}/log"];
    "/etc/apache2/vhosts.d/${horde_vhost}.conf":
    content => template("service_horde/horde_vhost.conf"),
    require => Exec['horde_webapp'];
  }

  exec { horde_db:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "sqlite ${horde_webroot}/storage/horde.db < ${horde_webroot}/scripts/sql/groupware.sql && chmod 664 ${horde_webroot}/storage/horde.db && chgrp $apache_grp ${horde_webroot}/storage/horde.db",
    unless => "test -e ${horde_webroot}/storage/horde.db",
    require => File["${horde_webroot}/storage"];
  }
}
