import 'os'
import 'os_gentoo'

# Class tool::system
#  Provides some common system tools
#
# Required parameters 
#
#  * sysadmin :
#
#  * mailserver :
#
#  * hostname :
#
#  * domainname :
#
# Optional parameters 
#
#  * :
#
# Templates
#
#  * :
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

      package { netkit-telnetd:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      gentoo_unmask { nagios-nsca:
        context  => 'service_nagios_nagios_nsca',
        package  => '=net-analyzer/nagios-nsca-2.7.2-r100',
        tag      => 'buildhost'
      }
      gentoo_keywords { nagios-nsca:
        context  => 'service_nagios_nagios_nsca',
        package  => '=net-analyzer/nagios-nsca-2.7.2-r100',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      package { nagios-nsca:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['nagios-nsca']
      }

      case $virtual {
        openvz:
        {
#           gentoo_mask { glibc:
#             context => 'tools_system_common_glibc',
#             package => '>sys-libs/glibc-2.5-r4',
#             tag     => 'buildhost'
#           }
#           gentoo_use_flags { glibc:
#             context => 'tools_system_common_glibc',
#             package => 'sys-libs/glibc',
#             use     => '-nptl -nptlonly',
#             tag     => 'buildhost'
#           }
          file { 
            '/etc/portage/package.mask/tools_system_common_glibc':
            ensure => 'absent';
            '/etc/portage/package.use/tools_system_common_glibc':
            ensure => 'absent';
          }

          package { glibc:
            category => 'sys-libs',
            ensure   => 'installed',
            tag      => 'buildhost'
          }
          package { iproute2:
            category => 'sys-apps',
            ensure   => 'installed',
            tag      => 'buildhost'
          }
        }
      }
    }
    default:
    {
    }
  }

  file {
    '/etc/nagios/send_nsca.cfg':
    content => template("tool_system/send_nsca.cfg_3.0.1"),
    mode    => 640,
    group   => 'nagios',
    require => Package['nagios-nsca'];
  }

  # Ensure the system knows how to handle the rxvt-unicode terminal
  file {
    '/usr/share/terminfo/r/rxvt-unicode':
    source => 'puppet:///tool_system/rxvt-unicode',
    require => Package['ncurses'];
  }

}
