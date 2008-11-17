import 'os_gentoo'

# Class service::openssh
#
#  Provides a configuration for the ssh daemon
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_openssh
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
  
  $template_openssh = template_version($version_openssh, '4.7_p1-r6@:4.7_p1-r6,', '4.7_p1-r6')

  $allow_root = get_var('sshd_allow_root', true)
  $allow_pass = get_var('sshd_allow_pass', false)
  $allow_x11  = get_var('desktop', false)
  $sshd_run_service = get_var('run_services', true)

  file { 
    '/etc/ssh/sshd_config':
    content => template("service_openssh/sshd_config_${template_openssh}"),
    require => Package['openssh'];
  }

  if defined(File['/etc/monit.d']) {
    file { 
      '/etc/monit.d/sshd':
      source => 'puppet:///service_openssh/monit_sshd';
    }
  }

  if $sshd_run_service {
    service { 'sshd':
      ensure    => 'running',
      enable    => true,
      require => Package['openssh'],
      subscribe => File['/etc/ssh/sshd_config'];
    }
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/sshd':
        ensure  => '/etc/init.d/sshd',
        require => Package['openssh']
      }
    }
  }
}
