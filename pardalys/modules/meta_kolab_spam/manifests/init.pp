import 'os'
import 'service_kolab'
import 'tool_pardalys'
import 'service_amavisd_new'
import 'service_clamav'
import 'service_spamassassin'
import 'service_dspam'

# Class meta::kolab::smtp
#
#  Defines the spam filtering part of a Kolab server
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_kolab_spam
#
class meta::kolab::spam {

  include os
  include service::kolab
  include tool::pardalys
  include service::amavisd_new
  include service::clamav
  include service::spamassassin
}
