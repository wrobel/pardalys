# Class tool::backupdir
#
#  Create a directory for backups.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_backupdir
#
class tool::backupdir {

  file { 'backup_directory':
    path => "${os::localstatedir}/backup",
    ensure => 'directory';
  }
}
