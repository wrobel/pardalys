import 'service_openldap'
import 'service_postfix'

# Class meta::kolab::smtp
#  Defines the SMTP server part of Kolab
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
class meta::kolab::smtp {

  include service::openldap
  include service::openldap::serve
  include service::postfix

}
