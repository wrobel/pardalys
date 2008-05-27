import 'os_gentoo'

# Class service::openssh
#  Provides a configuration for the ssh daemon
#
# Required parameters 
#
#  *  : 
#
# Optional parameters 
#
#  *  : 
#
# Templates
#
#  * templates/ : 
#
# Files
#
#  * files/ : 
#
class service::openssh {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { openssh:
        context => 'tools_system_common_openssh',
        package => 'net-misc/openssh',
        use     => 'chroot -tcpd',
        tag     => 'buildhost'
      }
      package { 'openssh':
        category => 'app-admin',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['openssh']
      }
    }
    default:
    {
      package { 'openssh':
        ensure   => 'installed'
      }
    }
  }
  
  # Convert to template version
  case $version_openssh {
    default: {
      crit("Unkown openssh version (Value: ${version_openssh})!")
      $template_openssh = 'UNKNOWN'
    }
    '4.7_p1-r6' : {
      $template_openssh = '4.7_p1-r6'
    }
  }

  case $template_openssh {
    'UNKNOWN': {
      crit("Cannot configure package without a valid version number!")
    }
    default : {

      $allow_root = get_var('sshd_allow_root', true)
      $allow_pass = get_var('sshd_allow_pass', false)
      $allow_x11  = get_var('desktop', false)

      file { 
        '/etc/ssh/sshd_config':
          content => template("service_openssh/sshd_config_${template_openssh}"),
          require => Package['openssh'],
          notify => Service['sshd'];
        '/etc/monit.d/sshd':
          source => 'puppet:///service_openssh/monit_sshd';
      }

      service { 'sshd':
        ensure    => 'running',
        enable    => true,
        require => Package['openssh']
      }

      case $operatingsystem {
        gentoo: {
          # Ensure that the service starts with the system
          file { '/etc/runlevels/default/sshd':
            ensure => '/etc/init.d/sshd',
            require  => Package['openssh']
          }
        }
      }

    }
  }
}
