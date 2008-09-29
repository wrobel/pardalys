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
      gentoo_keywords { 'Horde_Framework_freebusy':
        context => 'service_freebusy_Horde_Framework',
        package => '=dev-php/Horde_Framework-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_LDAP_freebusy':
        context => 'service_freebusy_Horde_LDAP',
        package => '=dev-php/Horde_LDAP-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_MIME_freebusy':
        context => 'service_freebusy_Horde_MIME',
        package => '=dev-php/Horde_MIME-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_DOM_freebusy':
        context => 'service_freebusy_Horde_DOM',
        package => '=dev-php/Horde_DOM-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_Server_freebusy':
        context => 'service_freebusy_Kolab_Server',
        package => '=dev-php/Horde_Kolab_Server-0.1.1.20080915',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Serialize_freebusy':
        context => 'service_freebusy_Horde_Serialize',
        package => '=dev-php/Horde_Serialize-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Date_freebusy':
        context => 'service_freebusy_Horde_Date',
        package => '=dev-php/Horde_Date-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Browser_freebusy':
        context => 'service_freebusy_Horde_Browser',
        package => '=dev-php/Horde_Browser-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Cipher_freebusy':
        context => 'service_freebusy_Horde_Cipher',
        package => '=dev-php/Horde_Cipher-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Cache_freebusy':
        context => 'service_freebusy_Horde_Cache',
        package => '=dev-php/Horde_Cache-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_History_freebusy':
        context => 'service_freebusy_Horde_History',
        package => '=dev-php/Horde_History-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_NLS_freebusy':
        context => 'service_freebusy_Horde_NLS',
        package => '=dev-php/Horde_NLS-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Secret_freebusy':
        context => 'service_freebusy_Horde_Secret',
        package => '=dev-php/Horde_Secret-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_DataTree_freebusy':
        context => 'service_freebusy_Horde_DataTree',
        package => '=dev-php/Horde_DataTree-0.0.3',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_SessionObjects_freebusy':
        context => 'service_freebusy_Horde_SessionObjects',
        package => '=dev-php/Horde_SessionObjects-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_Format_freebusy':
        context => 'service_freebusy_Kolab_Format',
        package => '=dev-php/Horde_Kolab_Format-0.1.2.20080912',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Auth_freebusy':
        context => 'service_freebusy_Horde_Auth',
        package => '=dev-php/Horde_Auth-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Group_freebusy':
        context => 'service_freebusy_Horde_Group',
        package => '=dev-php/Horde_Group-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Util_freebusy':
        context => 'service_freebusy_Horde_Util',
        package => '=dev-php/Horde_Util-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_iCalendar_freebusy':
        context => 'service_freebusy_Horde_iCalendar',
        package => '=dev-php/Horde_iCalendar-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Perms_freebusy':
        context => 'service_freebusy_Horde_Perms',
        package => '=dev-php/Horde_Perms-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_Storage_freebusy':
        context => 'service_freebusy_Kolab_Storage',
        package => '=dev-php/Kolab_Storage-0.1.0.20080925',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_FreeBusy':
        context => 'service_freebusy_Kolab_FreeBusy',
        package => '=dev-php/Kolab_FreeBusy-0.0.4.20080925',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Kolab_FreeBusy':
        category => 'dev-php',
        ensure   => 'installed',
        require  => [ Gentoo_keywords['Kolab_FreeBusy'],
                      Gentoo_keywords['Kolab_Storage_freebusy'],
                      Gentoo_keywords['Horde_Perms_freebusy'],
                      Gentoo_keywords['Horde_iCalendar_freebusy'],
                      Gentoo_keywords['Horde_Util_freebusy'],
                      Gentoo_keywords['Horde_Group_freebusy'],
                      Gentoo_keywords['Horde_Auth_freebusy'],
                      Gentoo_keywords['Kolab_Format_freebusy'],
                      Gentoo_keywords['Horde_SessionObjects_freebusy'],
                      Gentoo_keywords['Horde_DataTree_freebusy'],
                      Gentoo_keywords['Horde_Secret_freebusy'],
                      Gentoo_keywords['Horde_NLS_freebusy'],
                      Gentoo_keywords['Horde_History_freebusy'],
                      Gentoo_keywords['Horde_Cache_freebusy'],
                      Gentoo_keywords['Horde_Cipher_freebusy'],
                      Gentoo_keywords['Horde_Browser_freebusy'],
                      Gentoo_keywords['Horde_Date_freebusy'],
                      Gentoo_keywords['Horde_Serialize_freebusy'],
                      Gentoo_keywords['Kolab_Server_freebusy'],
                      Gentoo_keywords['Horde_DOM_freebusy'],
                      Gentoo_keywords['Horde_MIME_freebusy'],
                      Gentoo_keywords['Horde_LDAP_freebusy'],
                      Gentoo_keywords['Horde_Framework_freebusy']],
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

  $template_freebusy = template_version($version_kolab_freebusy, '0.0.3@:0.0.3,0.0.4.20080925@:0.0.4.20080925', '0.0.4.20080925')

  $sysconfdir  = $os::sysconfdir

  $freebusy_vhost = get_var('freebusy_vhost', 'localhost')
  $freebusy_vhost_path = get_var('freebusy_vhost_path', '/freebusy')

  $freebusy_webroot = "/var/www/${freebusy_vhost}/htdocs${freebusy_vhost_path}"

  $apache_allow_unauthenticated_fb = get_var('freebusy_allow_unauthenticated', false)

  $ldap_host    = get_var('ldap_host', 'localhost')
  $ldap_base_dn = get_var('base_dn')
  $ldap_bind_dn = get_var('bind_dn_nobody')
  $ldap_bind_pw = get_var('bind_pw_nobody')

  $imap_host    = get_var('imap_host', 'localhost')

  $maildomain = get_var('freebusy_maildomain', get_var('domainname'))

  $apache_usr = 'apache'
  $apache_grp = 'apache'

  exec { freebusy_webapp:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "webapp-config -I -h $freebusy_vhost -d $freebusy_vhost_path Kolab_FreeBusy $version_kolab_freebusy",
    unless => "test -e ${freebusy_webroot}/freebusy.php",
    require => Package['Kolab_FreeBusy'];
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
