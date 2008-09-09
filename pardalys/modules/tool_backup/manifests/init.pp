import 'os_gentoo'

# Class tool::backup
#  Basic /etc backup.
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
    require => Package['flexbackup'];
    '/etc/cron.daily/etc-backup':
    source  => 'puppet:///tool_backup/etc-backup.daily',
    mode    => 775,
    require => Package['flexbackup'];
    '/etc/cron.weekly/etc-backup':
    source  => 'puppet:///tool_backup/etc-backup.weekly',
    mode    => 775,
    require => Package['flexbackup'];
    '/etc/cron.monthly/etc-backup':
    source  => 'puppet:///tool_backup/etc-backup.monthly',
    mode    => 775,
    require => Package['flexbackup'];
  }
}
