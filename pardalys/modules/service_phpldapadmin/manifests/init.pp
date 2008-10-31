import 'os_gentoo'

# Class service::phpldapadmin
#
#  Provides phpLdapAdmin
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_phpldapadmin
#
class service::phpldapadmin {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { 'phpldapadmin':
        context => 'service_phpldapadmin_phpldapadmin',
        package => '=net-nds/phpldapadmin-1.1.0.5',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'phpldapadmin':
        category => 'net-nds',
        ensure   => 'installed',
        require  => Gentoo_keywords['phpldapadmin'],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'phpldapadmin':
        ensure  => 'installed';
      }
    }
  }

  $template_freebusy = template_version($version_phpldapadmin, '1.1.0.5@:1.1.0.5,', '1.1.0.5')

}
