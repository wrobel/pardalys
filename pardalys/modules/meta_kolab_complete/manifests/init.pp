import 'os'
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
  include service::openldap
}
