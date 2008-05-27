import 'os'
import 'os_gentoo'

# Class service::monit
#  Provides monit as a system monitor
#
# Required parameters 
#
#  * :
#
# Optional parameters 
#
#  * :
#
# Templates
#
#  * :
#
class service::monit {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      package { monit:
        category => 'app-admin',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { 'monit':
        ensure   => 'installed'
      }
    }
  }

  file { 'monit_config':
    path   => '/etc/monit.d',
    ensure => 'directory',
  }

  file { 'monit_lib':
    path   => '/var/lib/monit',
    ensure => 'directory',
  }

  # Convert to template version
  case $version_monit {
    default: {
      crit("Unkown monit version (Value: ${version_monit})!")
      $template_monit = 'UNKNOWN'
    }
    '4.8.2' : {
      $template_monit = '4.8.2'
    }
  }

  case $template_monit {
    'UNKNOWN': {
      crit("Cannot configure package without a valid version number!")
    }
    default : {
      # Monit node configuration
      file { 'service_monit_monitrc':
        path    => '/etc/monitrc',
        mode    => 600,
        content => template("service_monit/monitrc_${template_monit}"),
        require => Package['monit'],
        notify => Service["monit"]
      }

      service { "monit":
        ensure => running,
        enable => true,
        require => Package['monit']
      }

      case $operatingsystem {
        gentoo: {
          # Ensure that the service starts with the system
          file { '/etc/runlevels/default/monit':
            ensure => '/etc/init.d/monit',
            require  => Package['monit']
          }
        }
      }

    }
  }
}

