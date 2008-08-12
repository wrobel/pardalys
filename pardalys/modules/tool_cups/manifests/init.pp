import 'os_gentoo'

# Class tool::cups
#
#  Installs the cups printing system
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_cups
#
# @fact operatingsystem Allows to choose the correct package name
#                       depending on the operating system
# @fact keyword         The keyword for the system which is used to
#                       select unstable packages
#
class tool::cups {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { cups:
        context => 'tool_cups_cups',
        package => 'net-print/cups',
        use     => 'X tiff png',
        tag     => 'buildhost'
      }
      package { cups:
        category => 'net-print',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['cups'],
        tag      => 'buildhost'
      }

      package { foomatic-db:
        category => 'net-print',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      gentoo_use_flags { foo2zjs:
        context => 'tool_cups_foo2zjs',
        package => 'net-print/foo2zjs',
        use     => 'foomaticdb',
        tag     => 'buildhost'
      }
      gentoo_keywords { foo2zjs:
        context  => 'tool_cups_zoo2zjs',
        package  => '=net-print/foo2zjs-20080225',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { foo2zjs:
        category => 'net-print',
        ensure   => 'installed',
        require  => [ Gentoo_keywords['foo2zjs'], Gentoo_use_flags['foo2zjs']],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { cups:
        ensure   => 'installed',
      }
    }
  }

  $foozjs = get_var('foozjs', false)

  if $foozjs {
    @line {'make_conf_foo2zjs_devices':
      file => '/etc/portage/make.conf.puppet',
      line => "FOO2ZJS_DEVICES=\"$foozjs\"",
      tag => 'buildhost'
    }
  }
}
