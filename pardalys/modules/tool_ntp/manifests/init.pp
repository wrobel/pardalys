import 'os_gentoo'

# Class tool::ntp
#
#  Installs OpenNTP
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_ntp
#
class tool::ntp {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      package { openntpd:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { openntpd:
        ensure   => 'installed',
      }
    }
  }

  service { 'ntpd':
    ensure    => 'running',
    enable    => true,
    require => Package['openntpd'];
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/ntpd':
        ensure => '/etc/init.d/ntpd',
        require  => Package['openntpd']
      }
    }
  }
}
