import 'os_gentoo'

# Class service::cron
#  Provides a configuration for the cron system
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
# Plugins
#
#  * plugins/ : 
#
class service::cron {

  package { 'fcron':
    ensure  => 'installed',
    tag     => 'buildhost'
  }
  
  $template_fcron = template_version($version_fcron, '3.0.3@:3.0.3,', '3.0.3')

  $editor = get_var('global_editor', '/usr/bin/emacs')

  file { 
    '/etc/fcron/fcron.conf':
    content => template("service_cron/fcron.conf_${template_fcron}"),
    owner   => 'root',
    group   => 'fcron',
    mode    => 640,
    require => Package['fcron'],
    notify  => Service['fcron'];
    '/etc/monit.d/fcron':
    source  => 'puppet:///service_cron/monit_fcron';
  }

  service { 'fcron':
    ensure    => 'running',
    enable    => true,
    require => Package['fcron']
  }

  if defined(Package['logwatch']) {
    file {
    '/etc/logwatch/conf/services/cron.conf':
    source  => 'puppet:///service_cron/logwatch_plugin_cron.conf',
    require => Package['fcron'];
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
