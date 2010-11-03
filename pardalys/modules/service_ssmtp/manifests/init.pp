import 'os_gentoo'

# Class service::ssmtp
#
#  Provides a configuration for the ssmtp MTA
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_ssmtp
#
class service::ssmtp {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      # Keep the basic ssmtp mailer around
      gentoo_use_flags { 'ssmtp':
        context => 'service_ssmtp_ssmtp',
        package => 'mail-mta/ssmtp',
        use     => 'mailwrapper',
        tag     => 'buildhost'
      }
      package { 'ssmtp':
        category => 'mail-mta',
        ensure   => 'installed',
        require  => Gentoo_use_flags['ssmtp'],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'ssmtp':
        ensure  => 'installed';
      }
    }
  }

  $sysconfdir         = $os::sysconfdir

  $ssmtp_mailserver = get_var('mailserver', 'localhost')
  $ssmtp_hostname = get_var('hostname', 'localhost')
  $ssmtp_domainname = get_var('domainname', 'localdomain')

  file { 
    "$sysconfdir/mail/mailer.conf":
    source  => 'puppet:///service_ssmtp/mailer.conf',
    require => Package['ssmtp'];
    "$sysconfdir/ssmtp/ssmtp.conf":
    content => template("service_ssmtp/ssmtp.conf"),
    require => Package['ssmtp'];
    "$sysconfdir/revaliases":
    content => template("service_ssmtp/revaliases"),
    require => Package['ssmtp'];
  }
}
