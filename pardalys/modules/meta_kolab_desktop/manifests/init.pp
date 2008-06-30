import 'os'
import 'service_kolab'
import 'tool_pardalys'

# Class meta::kolab::desktop
#
#  Defines a desktop machine
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_kolab_monitor
#
class meta::kolab::monitor {
  include os
  include service::kolab
  include tool::pardalys
}
