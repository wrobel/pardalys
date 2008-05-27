import 'client_puppet_local'
import 'service_amavisd_new'
import 'service_clamav'
import 'service_spamassassin'
import 'service_dspam'

# Class service::amavisd_new
#  Defines the configuration for the amavisd_new mail filter
#
# Parameters 
#
#  * fqdnhostname: Define the fully qualified name of this host.
#
#  * service_amavisd_new_remote_servers: The remote machines that have
#    access to this amavisd machine
#
#  * service_amavisd_new_language: Identifies the language directory
#    for the templates under /etc/amavis/templates.
#
# Templates
#
#
class meta::kolab::spam {

  # FIXME: We need to get variables from a local
  # config file (kolab.globals)
  #$fqdnhostname = ''
  $local_addr = '127.0.0.1'
  $sbindir    = '/usr/sbin'
  $bindir     = '/usr/bin'

  $service_amavisd_new_remote         = 'yes'
  #$service_amavisd_new_remote_servers = []
  $service_amavisd_new_syslog         = 'yes'
  $service_amavisd_new_quarantine     = 'no'
  $service_amavisd_new_sa_local       = 'no'

  $service_clamav_amavis              = 'yes'
  $service_clamav_syslog              = 'yes'

  $service_spamassassin_amavisd       = 'yes'
  $service_spamassassin_amavisd_bayes = '/var/amavis/.spamassassin/bayes'
  $service_spamassassin_use_bayes     = 'yes'
  $service_spamassassin_use_pyzor     = 'yes'
  $service_spamassassin_use_razor     = 'yes'
  $service_spamassassin_use_dcc       = 'yes'
  $service_spamassassin_use_update    = 'yes'

  include client::puppet::local

  include service::amavisd_new
  include service::clamav
  include service::spamassassin
}
