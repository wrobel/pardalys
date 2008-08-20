import 'os_gentoo'

# Class tool::gpg
#
#  Provides the package installation for gpg
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_gpg
#
# @fact operatingsystem Allows to choose the correct package name
#                       depending on the operating system
# @fact keyword         The keyword for the system which is used to
#                       select unstable packages
#
class tool::gpg {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { gnupg:
        context => 'tool_gpg_gnupg',
        package => 'app-crypt/gnupg',
        use     => 'doc',
        tag     => 'buildhost'
      }
      package { gnupg:
        category => 'app-crypt',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['gnupg'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { gnupg:
        ensure   => 'installed',
      }
    }
  }
}
