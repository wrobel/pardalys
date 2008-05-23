import 'root'
import 'os'
import 'tool_pardalys'
import 'service_kolab'
import 'service_openldap'

# Class meta::kolab::complete
#
#  Defines a complete kolab server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_kolab_complete
#
class meta::kolab::complete {
  include os
  include tool::pardalys
  include service::kolab
  include service::openldap
  include service::openldap::serve
}
