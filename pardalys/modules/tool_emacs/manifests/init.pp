import 'os_gentoo'

# Class tool::emacs
#
#  Installs emacs and some addon packages
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_pardalys
#
# @fact operatingsystem Allows to choose the correct package name
#                       depending on the operating system
# @fact keyword         The keyword for the system which is used to
#                       select unstable packages
#
class tool::emacs {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { delicious:
        context  => 'tool_emacs_delicious',
        package  => '=app-emacs/delicious-0.3-r1',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { delicious:
        category => 'app-emacs',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['delicious'],
        tag      => 'buildhost'
      }
      package { emacs:
        category => 'app-editors',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { emacs:
        ensure   => 'installed',
      }
    }
  }
}
