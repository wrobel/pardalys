import 'os_gentoo'

# Class tool::logrotate
#
#  Provides a setup for log rotation.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_logrotate
#
class tool::logrotate {

  package { 'logrotate':
    ensure   => 'installed',
    tag      => 'buildhost'
  }
  
  $template_logrotate = template_version($version_logrotate, '3.7.2@:3.7.2,', '3.7.2')

  file { 
    '/etc/logrotate.conf':
    source => "puppet:///modules/tool_logrotate/logrotate.conf_${template_logrotate}",
    require => Package['logrotate'];
    '/var/backup/log':
    ensure => 'directory',
    require => File['backup_directory'];
  }

}
