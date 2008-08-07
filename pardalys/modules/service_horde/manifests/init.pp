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

  $template_horde_webmail = template_version($version_horde_webmail, '1.1.1@:1.1.1,', '1.1.1')

}
