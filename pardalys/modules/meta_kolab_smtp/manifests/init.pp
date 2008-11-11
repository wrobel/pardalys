import 'os'
import 'tool_openssl'
import 'tool_php'
import 'kolab_service_kolab'
import 'service_openldap'
import 'service_sasl'
import 'tool_php'
import 'tool_horde_framework'
import 'tool_cyrusimapadmin'
import 'tool_perl_kolab'
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
  include kolab::service::kolab
  include tool::openssl
  include tool::php
  include service::openldap
  include service::openldap::serve
  include service::sasl
  include tool::php
  include tool::horde::framework
  include tool::cyrusimapadmin
  include tool::perl::kolab
  include service::postfix
}
