import 'os_gentoo'

# Class tool::subversion
#
#  Provides the package installation for subversion
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_subversion
#
class tool::subversion {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      # FIXME: Remove the "apache2" USE flag once we serve no
      # subversion anymore
      gentoo_use_flags { subversion:
        context => 'tool_subversion_subversion',
        package => 'dev-vcs/subversion',
        use     => 'emacs bash-completion apache2 -dso',
        tag     => 'buildhost'
      }
      package { subversion:
        category => 'dev-vcs',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['subversion'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { subversion:
        ensure   => 'installed',
      }
    }
  }
}
