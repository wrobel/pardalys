import 'os_gentoo'

# Class tool::logrotate
#  Provides a setup for log rotation
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
#  * templates/ : 
#
class tool::logrotate {

  package { 'logrotate':
    ensure   => 'installed',
    tag      => 'buildhost'
  }
  
  $template_logrotate = template_version($version_logrotate, '3.7.2@:3.7.2,', '3.7.2')


  file { 
    '/etc/logrotate.conf':
    source => "puppet:///tool_logrotate/logrotate.conf_${template_logrotate}",
    require => Package['logrotate'];
    '/var/backup/log':
    ensure => 'directory';
  }

}
