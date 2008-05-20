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
# @fact operatingsystem Allows to choose the correct classes depending
#                       on the operating system
#
class os {
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
