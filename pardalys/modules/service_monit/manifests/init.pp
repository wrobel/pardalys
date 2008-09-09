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

  $template_monit = template_version($version_monit, '4.10.1@:4.10.1,', '4.10.1')

  $monit_user = get_var('monit_user', 'monit')
  $monit_pass = get_var('monit_pass', 'admin')

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

