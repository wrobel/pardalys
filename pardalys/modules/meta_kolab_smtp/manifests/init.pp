import 'os'
import 'service_kolab'
import 'service_openldap'
import 'service_sasl'
import 'service_postfix'

# Class meta::kolab::smtp
#
#  Defines the SMTP server part of a Kolab server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_postfix
#
class meta::kolab::smtp {

  include os
  include service::kolab
  include service::openldap
  include service::openldap::serve
  include service::sasl
  include service::postfix

}
