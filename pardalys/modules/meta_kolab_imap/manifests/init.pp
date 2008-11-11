import 'os'
import 'tool_openssl'
import 'kolab_service_kolab'
import 'service_openldap'
import 'service_sasl'
import 'service_cyrusimap'
import 'tool_perl_kolab'
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
  include tool::openssl
  include kolab::service::kolab
  include service::openldap
  include service::openldap::serve
  include service::sasl
  include service::cyrusimap
  include tool::perl::kolab
  include service::kolabd
}
