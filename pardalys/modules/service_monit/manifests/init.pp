import 'os'
import 'os_gentoo'

# Class service::monit
#
#  Provides monit as a system monitor.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_monit
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

  file { '/etc/monit.d':
    ensure => 'directory',
  }

  file { 'monit_lib':
    path   => '/var/lib/monit',
    ensure => 'directory',
  }

  $template_monit = template_version($version_monit, '4.10.1@:4.10.1,', '4.10.1')

  $monit_user = get_var('monit_user', 'monit')
  $monit_pass = get_var('monit_pass', '')
  $monit_mailserver = get_var('mailserver', 'localhost')
  $monit_hostname = get_var('hostname', 'localhost')
  $monit_domainname = get_var('domainname', 'localdomain')
  $monit_sysadmin = get_var('kolab_admin_mail',   'root@localhost')
  $monit_run_service = get_var('run_services', true)

  $monit_cert_path = $tool::openssl::ssl_combined_path

  # Monit node configuration
  file { '/etc/monitrc':
    mode    => 600,
    content => template("service_monit/monitrc_${template_monit}"),
    require => Package['monit'],
  }

  if $monit_run_service {
    service { "monit":
      ensure => running,
      enable => true,
      require => Package['monit'],
      subscribe => File['/etc/monitrc']
    }
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

