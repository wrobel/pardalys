import 'os'
import 'tool_openssl'
import 'service_kolab'
import 'service_openldap'
import 'service_cyrusimap'
import 'service_kolabd'

# Class meta::kolab::imap
#
#  Defines the IMAP server part of a Kolab server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_postfix
#
class meta::kolab::imap {

  include os
  include service::kolab
  include tool::openssl
  include service::openldap
  include service::openldap::serve
  include service::cyrusimap
  include service::kolabd
}
