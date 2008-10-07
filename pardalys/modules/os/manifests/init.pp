import 'os_gentoo'

# Class os
#
#  Handle tasks specific to different operating systems
#
#  The class currently supports the following operating systems:
#
#    - Gentoo (http://www.gentoo.org)
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os
#
class os {

  $sysconfdir    = '/etc'
  $sbindir       = '/usr/sbin'
  $bindir        = '/usr/bin'
  $localstatedir = '/var'
  $sysrundir     = "${localstatedir}/run"
  $statelibdir   = "${localstatedir}/lib"
  $logdir        = "${localstatedir}/log"

  case $operatingsystem {
    gentoo: {
      include gentoo::etc::portage::backup
      include gentoo::etc::portage
      include gentoo::etc::portage::restore
    }
    default: {
    }
  }
}
