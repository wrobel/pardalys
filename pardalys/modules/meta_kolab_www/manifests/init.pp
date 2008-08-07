import 'os'
import 'service_apache'

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
  include service::apache

}
