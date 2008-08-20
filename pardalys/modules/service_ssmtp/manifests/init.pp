import 'os_gentoo'

# Class service::ssmtp
#
#  Provides a configuration for the ssmtp MTA
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_ssmtp
#
# @module root           The root module is required to determine the installed
#                        postfix version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
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

  $mailserver = get_var('mailserver')
  $domainname = get_var('domainname')

  file { 
    "$sysconfdir/mail/mailer.conf":
    source  => 'puppet:///service_ssmtp/mailer.conf',
    require => Package['ssmtp'];
    "$sysconfdir/ssmtp.conf":
    content => template("service_ssmtp/ssmtp.conf"),
    require => Package['ssmtp'];
    "$sysconfdir/revaliases":
    content => template("service_ssmtp/revaliases"),
    require => Package['ssmtp'];
  }
}
