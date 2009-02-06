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
       gentoo_keywords { 'horde-hermes':
       context => 'service_horde_hermes',
       package => '=www-apps/horde-hermes-1.0_rc2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_use_flags { 'horde-hermes':
        context => 'service_horde_hermes',
        package => 'www-apps/horde-hermes',
        use     => 'kolab',
        tag     => 'buildhost'
      }
      package { 'horde-hermes':
        category => 'www-apps',
        ensure   => 'installed',
        require  => [Gentoo_use_flags['horde-hermes'], Gentoo_keywords['horde-hermes']],
        tag      => 'buildhost';
      }
      gentoo_keywords { 'horde-webmail':
        context => 'service_horde_webmail',
        package => 'www-apps/horde-webmail',
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
      package { 'aspell':
        category => 'app-text',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      package { 'aspell-de':
        category => 'app-dicts',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      package { 'aspell-en':
        category => 'app-dicts',
        ensure   => 'installed',
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

  $template_horde_webmail = template_version($version_horde_webmail, '1.1.2-r1(1.1.2-r1)@1.2_rc1(1.2_rc1):1.1.2-r1,', '1.1.2-r1')

  case $version_horde_webmail {
    '1.2_rc1(1.2_rc1)':
    {
      $version_hw = '1.2_rc1'
    }
  }

  case $version_horde_hermes {
    '1.0_rc2(1.0_rc2)':
    {
      $webapp_version_hermes = '1.0_rc2'
    }
  }

  $sysconfdir  = $os::sysconfdir

  $horde_vhost = get_var('horde_vhost', 'localhost')
  $horde_vhost_path = get_var('horde_vhost_path', '/horde')

  $horde_webroot = "/var/www/${horde_vhost}/htdocs${horde_vhost_path}"

  $sysadmin = get_var('kolab_admin_mail', 'root@localhost')
  $horde_maildomain = get_var('horde_maildomain', get_var('domainname'))

  $horde_admins = split(get_var('horde_admins', ''), ',')
  $mailserver = get_var('mailserver', 'localhost')

  $horde_vhost_redirectors = split(get_var('horde_vhost_redirectors', ''), ',')
  $dimp_vhost_redirectors = split(get_var('dimp_vhost_redirectors', ''), ',')

  $ldap_host    = get_var('ldap_host', 'localhost')
  $ldap_base_dn = get_var('base_dn')
  $ldap_bind_dn = get_var('bind_dn_nobody')
  $ldap_bind_pw = get_var('bind_pw_nobody')

  $imap_host    = get_var('imap_host', 'localhost')

  $apache_usr = 'apache'
  $apache_grp = 'apache'

  exec { horde_webapp:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "webapp-config -I -h $horde_vhost -d $horde_vhost_path horde-webmail $version_hw",
    unless => "test -e ${horde_webroot}/index.php",
    require => Package['horde-webmail'];
  }

  exec { hermes_webapp:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "webapp-config -I -h $horde_vhost -d $horde_vhost_path/hermes horde-hermes $webapp_version_hermes",
    unless => "test -e ${horde_webroot}/hermes/index.php",
    require => Package['horde-hermes'];
  }

  file {
    "${horde_webroot}/config/kolab.php":
    content => template("service_horde/horde_kolab.php_$template_horde_webmail"),
    require => Exec['horde_webapp'];
    "${horde_webroot}/kronolith/config/kolab.php":
    content => template("service_horde/kronolith_kolab.php_$template_horde_webmail"),
    require => Exec['horde_webapp'];
    "${sysconfdir}/apache2/vhosts.d/${horde_vhost}_horde.conf":
    content => template('service_horde/horde_vhost.conf'),
    require => Exec['horde_webapp'];
  }

}
