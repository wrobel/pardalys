import 'os_gentoo'

# Class tool::system::desktop
#
#  Provides some desktop specific tools.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_system_desktop
#
class tool::system::desktop {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      # 0.6.0 does not compile for me
      gentoo_keywords { libmcs:
        context  => 'tool_system_desktop_libmcs',
        package  => '=dev-libs/libmcs-0.7.1-r2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }

      gentoo_keywords { luma:
        context  => 'tool_system_desktop_luma',
        package  => '=net-nds/luma-2.4',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { luma:
        category => 'net-nds',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['luma'],
        tag      => 'buildhost'
      }
    }
    ubuntu:
    {
      package { ubuntu-netbook: ensure   => 'installed' }
      package { mplayer: ensure   => 'installed' }
      package { luma: ensure   => 'installed' }
      package { twinkle: ensure   => 'installed' }
      package { skype: ensure   => 'installed' }
      package { gimp: ensure   => 'installed' }
      package { gimp-help-common: ensure   => 'installed' }
      package { gimp-help-de: ensure   => 'installed' }
      package { taxbird: ensure   => 'installed' }
    }
    default:
    {
      package { luma: ensure   => 'installed' }
    }
  }
}
