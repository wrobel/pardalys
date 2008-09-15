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
      gentoo_keywords { 'Kolab_Server':
        context => 'service_Kolab_Server',
        package => '=dev-php/Kolab_Server-0.1.1',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Kolab_Server':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Kolab_Server'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Serialize':
        context => 'service_Horde_Serialize',
        package => '=dev-php/Horde_Serialize-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Serialize':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Serialize'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Date':
        context => 'service_Horde_Date',
        package => '=dev-php/Horde_Date-0.0.2.20080912',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Date':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Date'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Browser':
        context => 'service_Horde_Browser',
        package => '=dev-php/Horde_Browser-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Browser':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Browser'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Cipher':
        context => 'service_Horde_Cipher',
        package => '=dev-php/Horde_Cipher-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Cipher':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Cipher'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Cache':
        context => 'service_Horde_Cache',
        package => '=dev-php/Horde_Cache-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Cache':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Cache'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_History':
        context => 'service_Horde_History',
        package => '=dev-php/Horde_History-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_History':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_History'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_NLS':
        context => 'service_Horde_NLS',
        package => '=dev-php/Horde_NLS-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_NLS':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_NLS'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Secret':
        context => 'service_Horde_Secret',
        package => '=dev-php/Horde_Secret-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Secret':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Secret'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_DataTree':
        context => 'service_Horde_DataTree',
        package => '=dev-php/Horde_DataTree-0.0.3',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_DataTree':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_DataTree'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_SessionObjects':
        context => 'service_Horde_SessionObjects',
        package => '=dev-php/Horde_SessionObjects-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_SessionObjects':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_SessionObjects'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Kolab_Format':
        context => 'service_Kolab_Format',
        package => '=dev-php/Kolab_Format-0.1.2.20080912',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Kolab_Format':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Kolab_Format'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Auth':
        context => 'service_Horde_Auth',
        package => '=dev-php/Horde_Auth-0.0.3.20080912',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Auth':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Auth'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Group':
        context => 'service_Horde_Group',
        package => '=dev-php/Horde_Group-0.0.2.20080912',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Group':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Group'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Horde_Perms':
        context => 'service_Horde_Perms',
        package => '=dev-php/Horde_Perms-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Perms':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Horde_Perms'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Kolab_Storage':
        context => 'service_Kolab_Storage',
        package => '=dev-php/Kolab_Storage-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Kolab_Storage':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Kolab_Storage'],
        tag      => 'buildhost';
      }

      gentoo_keywords { 'Kolab_FreeBusy':
        context => 'service_Kolab_FreeBusy',
        package => '=dev-php/Kolab_FreeBusy-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Kolab_FreeBusy':
        category => 'dev-php',
        ensure   => 'installed',
        require  => Gentoo_use_flags['Kolab_FreeBusy'],
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

  $template_freebusy = template_version($version_freebusy, '0.0.2@:0.0.2,', '0.0.2')

  $freebusy_vhost = get_var('freebusy_vhost', 'localhost')
  $freebusy_vhost_path = get_var('freebusy_vhost_path', '/freebusy')

  $freebusy_webroot = "/var/www/${freebusy_vhost}/htdocs${freebusy_vhost_path}"

  $ldap_host    = get_var('pardalys_ldapserver', 'localhost')
  $ldap_base_dn = get_var('base_dn')
  $ldap_bind_dn = get_var('bind_dn_nobody')
  $ldap_bind_pw = get_var('bind_pw_nobody')

  $imap_host    = get_var('imap_host', 'localhost')

  $apache_usr = 'apache'
  $apache_grp = 'apache'

  exec { freebusy_webapp:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "webapp-config -I -h $freebusy_vhost -d $freebusy_vhost_path Kolab_FreeBusy $template_freebusy",
    unless => "test -e ${freebusy_webroot}/index.php",
    require => Package['Kolab_FreeBusy'];
  }

  file {
    "${freebusy_webroot}/config.php":
    content => template("service_freebusy/freebusy_config.php_$template_freebusy"),
    require => Exec['freebusy_webapp'];
  }

}
