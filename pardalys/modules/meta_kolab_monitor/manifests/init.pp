import 'os'
import 'kolab_service_kolab'
import 'tool_openssl'
import 'service_lighttpd'
import 'service_logwatch'
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
  include kolab::service::kolab
  include tool::openssl
  include service::lighttpd
  include service::logwatch
#  include service::nagios
}
