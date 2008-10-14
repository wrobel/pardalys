import 'os'
import 'kolab_service_kolab'
import 'tool_cups'
import 'tool_gfx'
import 'tool_system_desktop'

# Class meta::kolab::desktop
#
#  Defines a desktop machine
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_kolab_monitor
#
class meta::de::pardus::desktop {
  include os
  include kolab::service::kolab
  include tool::cups
  include tool::gfx
  include tool::system::desktop
}
