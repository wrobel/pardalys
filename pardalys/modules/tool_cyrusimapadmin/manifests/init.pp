import 'os_gentoo'

# Class tool::cyrusimapadmin
#
#  Installs the Cyrus IMAP admin.
#
# Parameters 
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_cyrusimap
#
# @module root           The root module is required to determine the installed
#                        amavis version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
# @module kolab_service_kolab  Provides the kolab configuration.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
#
#
class tool::cyrusimapadmin {

  # Package installation
  case $operatingsystem {
    gentoo: {
      gentoo_keywords { 'cyrus-imap-admin':
        context  => 'service_cyrusimap_cyrus_imap_admin',
        package  => '=net-mail/cyrus-imap-admin-2.3.13',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_use_flags { "cyrus-imap-admin":
        context => 'service_cyrusimap_cyrus_imap_admin',
        package => 'net-mail/cyrus-imap-admin',
        use     => 'kolab ssl'
      }
      package { 'cyrus-imap-admin':
        category => 'net-mail',
        ensure   => 'installed',
        require  => [ Gentoo_use_flags['cyrus-imap-admin'],
                      Gentoo_keywords['cyrus-imap-admin']],
        tag      => 'buildhost'
      }
    }
    default: {
      package { 'cyrus-imap-admin':
        ensure   => 'installed';
      }
    }
  }
}
