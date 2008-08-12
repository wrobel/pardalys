import 'os'
import 'tool_layman'
import 'tool_baselayout'
import 'tool_bash'
import 'tool_emacs'
import 'tool_portage'
import 'tool_system'
import 'client_puppet_local'
import 'service_syslog'
import 'service_cron'
import 'service_openssh'
import 'service_monit'
import 'service_ssmtp'

# Class meta::pardus::common
#  A common set of configurations used on p@rdus servers
#
class meta::de::pardus::common {

  include os
  include tool::layman
  include tool::baselayout
  include tool::bash
  include tool::emacs
  include tool::portage
  include tool::system
  include client::puppet::local
  include service::monit
  include service::syslog
  include service::cron
  include service::openssh
  include service::ssmtp

}
