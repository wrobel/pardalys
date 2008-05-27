import 'service_lighttpd'
import 'service_logwatch'
import 'service_munin'
import 'service_nagios'

# Class meta::kolab::monitor
#  Combines monitoring tools for the Kolab server
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
class meta::kolab::monitor {

  include service::munin
}

class meta::kolab::monitor::master {

  include service::lighttpd
  include service::logwatch
  include service::munin
  include service::munin::master
  include service::nagios
}
