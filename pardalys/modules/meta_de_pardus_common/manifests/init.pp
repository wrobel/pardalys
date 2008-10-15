import 'os'
import 'tool_gpg'
import 'tool_layman'
import 'tool_backupdir'
import 'tool_backup'
import 'tool_baselayout'
import 'tool_bash'
import 'tool_emacs'
import 'tool_logrotate'
import 'tool_openssl'
import 'service_openldap'
import 'tool_pardalys'
import 'tool_portage'
import 'tool_subversion'
import 'tool_system'
import 'tool_php'
import 'service_monit'
import 'service_syslog'
import 'service_cron'
import 'service_openssh'
import 'service_ssmtp'

# Class meta::pardus::common
#  A common set of configurations used on p@rdus servers
#
class meta::de::pardus::common {

  include os
  include tool::gpg
  include tool::layman
  include tool::backupdir
  include tool::backup
  include tool::baselayout
  include tool::bash
  include tool::emacs
  include tool::logrotate
  include tool::openssl
  include service::openldap
  include tool::pardalys
  include tool::portage
  include tool::subversion
  include tool::system
  include tool::php
  include service::monit
  include service::syslog
  include service::cron
  include service::openssh
  include service::ssmtp
}
