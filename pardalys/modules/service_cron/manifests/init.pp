import 'os_gentoo'

# Class service::cron
#
#  Provides a configuration for the cron system.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_cron
#
class service::cron {

  package { 'fcron':
    ensure  => 'installed',
    tag     => 'buildhost'
  }
  
  $template_fcron = template_version($version_fcron, '3.0.3@:3.0.3,', '3.0.3')

  $editor = get_var('global_editor', '/usr/bin/emacs')
  $cron_sysadmin = get_var('kolab_admin_mail', 'root@localhost')
  $cron_run_service = get_var('run_services', true)
  $cron_system_continuous = get_var('system_continuous', true)

  group {'fcron':
    ensure => 'present',
    provider => 'groupadd',
    require => Package['fcron']
  }

  file { 
    '/etc/fcron/fcron.conf':
    content => template("service_cron/fcron.conf_${template_fcron}"),
    owner   => 'root',
    group   => 'fcron',
    mode    => 640,
    require => Package['fcron'];
    '/etc/crontab':
    content => template("service_cron/crontab");
  }

  if defined(File['/etc/monit.d']) {
    file { 
      '/etc/monit.d/fcron':
      source  => 'puppet:///service_cron/monit_fcron';
    }
  }

  exec { root_crontab:
    path => "/usr/bin:/usr/sbin:/bin",
    command => "crontab /etc/crontab",
    require => [File['/etc/crontab'], Package['fcron']],
    unless => "test -e /var/spool/fcron/root -o -e /var/spool/fcron/new.root"
  }

  if $cron_run_service {
    service { 'fcron':
      ensure    => 'running',
      enable    => true,
      require => Package['fcron'],
      subscribe => File['/etc/fcron/fcron.conf'];
    }
  }

  if defined(Package['logwatch']) {
    file {
    '/etc/logwatch/conf/services/cron.conf':
    source  => 'puppet:///service_cron/logwatch_plugin_cron.conf';
    }
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/fcron':
        ensure => '/etc/init.d/fcron',
        require  => Package['fcron']
      }
    }
  }
}
