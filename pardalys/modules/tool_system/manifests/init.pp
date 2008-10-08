import 'os'
import 'os_gentoo'

# Class tool::system
#
#  Provides some common system tools
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_system
#
class tool::system {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { perl:
        context => 'tools_system_common_perl',
        package => 'dev-lang/perl',
        use     => '"berkdb gdbm',
        tag     => 'buildhost'
      }
      package { perl:
        category => 'dev-lang',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['perl']
      }

      gentoo_use_flags { libpcre:
        context => 'tools_system_common_libpcre',
        package => 'dev-libs/libpcre',
        use     => 'cxx zlib bzip2 unicode',
        tag     => 'buildhost'
      }
      package { libpcre:
        category => 'dev-libs',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['libpcre']
      }

      gentoo_use_flags { ncurses:
        context => 'tools_system_common_ncurses',
        package => 'sys-libs/ncurses',
        use     => 'doc unicode',
        tag     => 'buildhost'
      }
      package { ncurses:
        category => 'sys-libs',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['ncurses']
      }

      # for the hostx tool
      package { host:
        category => 'net-dns',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { unzip:
        category => 'app-arch',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['libpcre']
      }

      package { slocate:
        category => 'sys-apps',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { sqlite:
        category => 'dev-db',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { strace:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { ltrace:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { dhcpcd:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { netkit-telnetd:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      gentoo_keywords { scripts-gw:
        context  => 'tool_system_scripts-gw',
        package  => '=app-misc/scripts-gw-1.3.2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { scripts-gw:
        category => 'app-misc',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['scripts-gw']
      }

      package { iproute2:
        category => 'sys-apps',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
    }
    default:
    {
    }
  }

  file {
    '/etc/cron.daily/check_security':
    source => 'puppet:///tool_system/check_security',
    mode    => 755;
    '/root/.log':
    ensure => 'directory';
  }

  # Ensure the system knows how to handle the rxvt-unicode terminal
  file {
    '/usr/share/terminfo/r/rxvt-unicode':
    source => 'puppet:///tool_system/rxvt-unicode',
    require => Package['ncurses'];
  }

}
