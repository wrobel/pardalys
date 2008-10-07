# Class tool::backup
#
#  Basic /etc backup.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_backup
#
class tool::backup {

  # Package installation
  package { 
    'flexbackup':
    ensure   => 'installed',
    tag      => 'buildhost';
  }

  file { 
    '/etc/flexbackup.conf':
    source  => 'puppet:///tool_backup/flexbackup.conf',
    require => [Package['flexbackup'], File['backup_directory']];
    '/etc/cron.daily/etc-backup':
    source  => 'puppet:///tool_backup/etc-backup.daily',
    mode    => 775,
    require => [Package['flexbackup'], File['backup_directory']];
    '/etc/cron.weekly/etc-backup':
    source  => 'puppet:///tool_backup/etc-backup.weekly',
    mode    => 775,
    require => [Package['flexbackup'], File['backup_directory']];
    '/etc/cron.monthly/etc-backup':
    source  => 'puppet:///tool_backup/etc-backup.monthly',
    mode    => 775,
    require => [Package['flexbackup'], File['backup_directory']];
  }
}
