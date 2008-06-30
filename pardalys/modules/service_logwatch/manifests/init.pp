import 'os'
import 'os_gentoo'

# Class service::logwatch
#  Provides logwatch as a system logwatchor
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
class service::logwatch {

  package { logwatch:
    ensure   => 'installed',
    tag      => 'buildhost'
  }

  $template_version = template_version($version_logwatch, '7.3.2@:7.3.2,')

  case $template_version {
    'UNKNOWN': {
      $template_version = '7.3.2'
      crit("Unknown package version! Will configure for version ${template_version}.")
    }
  }

  # Get the logwatch services we have
  $my_logwatch_services = split($logwatch_services, ',')

  file {
    '/etc/logwatch/':
    ensure  => 'directory';
    '/etc/logwatch/conf':
    ensure  => 'directory',
    require => File['/etc/logwatch/'];
    '/etc/logwatch/conf/logfiles':
    ensure  => 'directory',
    require => File['/etc/logwatch/conf'];
    '/etc/logwatch/conf/services':
    ensure  => 'directory',
    require => File['/etc/logwatch/conf'];
    '/etc/logwatch/scripts':
    ensure  => 'directory',
    require => File['/etc/logwatch/'];
    '/etc/logwatch/scripts/services':
    ensure  => 'directory',
    require => File['/etc/logwatch/scripts'];
    '/etc/logwatch/conf/logwatch.conf':
    mode    => 644,
    content => template("service_logwatch/logwatch.conf_${template_version}"),
    require => Package['logwatch'],
    require => File['/etc/logwatch/conf'];
    '/etc/logwatch/conf/logfiles/messages.conf':
    source  => 'puppet:///service_logwatch/messages.conf',
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => File['/etc/logwatch/conf/logfiles'];
    '/usr/sbin/logwatch.pl':
    source  => 'puppet:///service_logwatch/logwatch.pl',
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    require => Package['logwatch'];
    '/usr/share/logwatch/default.conf/logwatch.conf':
    ensure  => 'absent',
    require => Package['logwatch'];
    '/etc/cron.daily/00-logwatch':
    source  => 'puppet:///service_logwatch/00-logwatch',
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    require => Package['logwatch'];
  }
}
