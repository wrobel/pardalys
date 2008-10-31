import 'os'
import 'tool_openssl'
import 'tool_php'
import 'tool_horde_framework'
import 'tool_portage_extend'
import 'service_apache'
import 'service_horde'
import 'service_freebusy'
import 'service_phpldapadmin'

# Class meta::kolab::apache
#
#  Defines the webserver part of a Kolab server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_kolab_apache
#
class meta::kolab::www {

  include os
  include tool::openssl
  include tool::php
  include tool::horde::framework
  include service::apache
  include service::apache
  include service::horde
  include service::freebusy
  include service::phpldapadmin
}
