import 'os'
import 'service_kolab'
import 'tool_pardalys'
import 'service_lighttpd'
import 'service_logwatch'
import 'service_munin'
import 'service_nagios'

# Class meta::kolab::monitor
#
#  Combines monitoring tools for the Kolab server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_kolab_monitor
#
class meta::kolab::monitor {

  include service::munin
}

class meta::kolab::monitor::master {

  include os
  include service::kolab
  include tool::pardalys
  include service::lighttpd
  include service::logwatch
  include service::munin
  include service::munin::master
  include service::nagios
}
