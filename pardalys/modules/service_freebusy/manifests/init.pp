import 'os_gentoo'

# Class service::freebusy
#
#  Provides the Freebusy configuration for the Kolab Server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_freebusy
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
class service::freebusy {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { 'PEAR_PEAR':
        context => 'PEAR_PEAR',
        package => '>=dev-php/PEAR-PEAR-1.7.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_FreeBusy':
        context => 'service_freebusy_Kolab_FreeBusy',
        package => '=dev-php/Horde_Kolab_FreeBusy-0.1.2',
        keywords => "~$keyword",
        tag     => 'buildhost',
        require => [ Gentoo_keywords['PEAR_PEAR'] ]
      }
      package { 'Horde_Kolab_FreeBusy':
        category => 'dev-php',
        ensure   => 'installed',
        require  => [ Gentoo_keywords['Kolab_FreeBusy'],
                      Package['Horde_Kolab_Storage'] ],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'Kolab_FreeBusy':
        ensure  => 'installed';
      }
    }
  }

  $template_freebusy = template_version($version_horde_kolab_freebusy, '0.0.3@:0.0.3,0.0.4.20081001@0.1.2@:0.0.4.20081001', '0.0.4.20081001')

  $sysconfdir  = $os::sysconfdir

  $freebusy_vhost = get_var('freebusy_vhost', 'localhost')
  $freebusy_vhost_path = get_var('freebusy_vhost_path', '/freebusy')

  $freebusy_webroot = "/var/www/${freebusy_vhost}/htdocs${freebusy_vhost_path}"

  $apache_allow_unauthenticated_fb = get_var('freebusy_allow_unauthenticated', false)

  $ldap_uri     = get_var('kolab_ldap_uri', 'localhost')
  $ldap_base_dn = get_var('kolab_base_dn')
  $ldap_bind_dn = get_var('kolab_bind_dn_restricted')
  $ldap_bind_pw = get_var('kolab_bind_pw_restricted')

  $imap_host    = get_var('imap_host', 'localhost')

  $maildomain = get_var('freebusy_maildomain', get_var('domainname'))
  $sysadmin = get_var('kolab_admin_mail', 'root@localhost')

  $apache_usr = 'apache'
  $apache_grp = 'apache'

  # FIXME: I really need to return to webapp-config
  exec { freebusy_webapp:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "webapp-config -I -h $freebusy_vhost -d $freebusy_vhost_path Horde_Kolab_FreeBusy $version_horde_kolab_freebusy",
    unless => "test -e ${freebusy_webroot}/freebusy.php",
    require => Package['Horde_Kolab_FreeBusy'];
  }

  file {
    "${freebusy_webroot}/config.php":
    content => template("service_freebusy/freebusy_config.php_$template_freebusy"),
    require => Exec['freebusy_webapp'];
    "${sysconfdir}/apache2/vhosts.d/${freebusy_vhost}_freebusy.conf":
    content => template('service_freebusy/freebusy_vhost.conf'),
    require => Exec['freebusy_webapp'];
  }

}
