import 'os_gentoo'

# Class tool::gfx
#
#  Provides graphic tools.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_gfx
#
class tool::gfx {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { potracegui:
        context  => 'tool_gfx_potracegui',
        package  => '=media-gfx/potracegui-1.3.4',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { potracegui:
        category => 'media-gfx',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['potracegui'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { potracegui:
        ensure   => 'installed',
      }
    }
  }
}
