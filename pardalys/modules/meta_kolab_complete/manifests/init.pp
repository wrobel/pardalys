import 'root'
import 'os'
import 'kolab_service_kolab'
import 'tool_openssl'
import 'service_openldap'
import 'service_sasl'
import 'tool_cyrusimapadmin'
import 'tool_perl_kolab'
import 'tool_php'
import 'tool_horde_framework'
import 'service_postfix'
import 'service_cyrusimap'
import 'service_kolabd'
import 'tool_portage_extend'
import 'service_apache'
import 'service_horde'
import 'service_freebusy'
import 'service_phpldapadmin'

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
  include kolab::service::kolab
  include tool::openssl
  include service::openldap
  include service::openldap::serve
  case $kolab_slapd_recovery {
    default: {
      include service::sasl
      include tool::perl::kolab
      include tool::php
      include tool::horde::framework
      include service::postfix
      include tool::cyrusimapadmin
      include service::cyrusimap
      include service::kolabd
      include tool::portage::extend
      include service::apache
      include service::horde
      include service::freebusy
      include service::phpldapadmin
    }
    "true": {
      crit('LDAP recovery - Any additional Kolab configuration files remain untouched.')
    }
  }

}
