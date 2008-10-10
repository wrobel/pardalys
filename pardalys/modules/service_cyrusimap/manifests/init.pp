import 'os_gentoo'

# Class service::cyrusimap
#
#  Defines the configuration for the Cyrus IMAP server
#
# Parameters 
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_cyrusimap
#
# @module root           The root module is required to determine the installed
#                        amavis version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
# @module kolab_service_kolab  Provides the kolab configuration.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
#
# @fact version_cyrusimap   The cyrus-imap version currently installed
#
class service::cyrusimap {

  # Package installation
  case $operatingsystem {
    gentoo: {
      gentoo_keywords { 'cyrus-imapd':
        context  => 'service_cyrusimap_cyrus_imapd',
        package  => '=net-mail/cyrus-imapd-2.3.12_p2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_use_flags {
        'cyrus-imapd':
          context => 'service_cyrusimap_cyrus_imapd',
          package => 'net-mail/cyrus-imapd',
          use     => 'kolab ssl'
      }
      package { 'cyrus-imapd':
        category => 'net-mail',
        ensure   => 'installed',
        require  => [ Gentoo_use_flags['cyrus-imapd'],
                      Gentoo_keywords['cyrus-imapd']],
        tag      => 'buildhost'
      }
      gentoo_keywords { 'cyrus-imap-admin':
        context  => 'service_cyrusimap_cyrus_imap_admin',
        package  => '=net-mail/cyrus-imap-admin-2.3.12_p2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_use_flags { "cyrus-imap-admin":
        context => 'service_cyrusimap_cyrus_imap_admin',
        package => 'net-mail/cyrus-imap-admin',
        use     => 'kolab ssl'
      }
      package { 'cyrus-imap-admin':
        category => 'net-mail',
        ensure   => 'installed',
        require  => [ Gentoo_use_flags['cyrus-imap-admin'],
                      Gentoo_keywords['cyrus-imap-admin']],
        tag      => 'buildhost'
      }
    }
    default: {
      package { 'cyrus-imapd':
        ensure   => 'installed';
      }
    }
  }

  $sysconfdir         = $os::sysconfdir

  $template_imapd = template_version($version_imapd, '2.3.12_p2@:2.3.12_p2,', '2.3.12_p2')

  $lmtp_socket   = '/var/imap/socket/lmtp'
  $notify_socket = '/var/imap/socket/notify'
  $sievedir      = '/var/imap/sieve'
  $statedir      = '/var/imap'
  $spooldir      = '/var/spool/imap'
  $lmtp_external   = get_var('imap_lmtp_external', false)
  $cyrus_admins    = get_var('kolab_cyrus_admins')
  $allow_anonymous = get_var('imap_allow_anonymous', 'no')
  $sendmail = '/usr/sbin/sendmail'

  $ssl_cert_path  = $tool::openssl::ssl_cert_path
  $ssl_key_path   = $tool::openssl::ssl_key_path

  file { 
    "${sysconfdir}/cyrus.conf":
      content => template("service_cyrusimap/cyrus.conf_${template_imapd}"),
      mode    => 640,
      owner => 'cyrus',
      group => 'mail',
#      notify  => Service['cyrus-imapd'],
      require => Package['cyrus-imapd'];
    "${sysconfdir}/imapd.conf":
      content => template("service_cyrusimap/imapd.conf_${template_imapd}"),
      mode    => 640,
      owner => 'cyrus',
      group => 'mail',
#      notify  => Service['cyrus-imapd'],
      require => Package['cyrus-imapd'];
    "${sysconfdir}/imapd.groups":
      content => template("service_cyrusimap/imapd.groups_${template_imapd}"),
      mode    => 640,
      owner => 'cyrus',
      group => 'mail',
#      notify  => Service['cyrus-imapd'],
      require => Package['cyrus-imapd'];
    "${sysconfdir}/imapd.annotation_definitions":
      source => "puppet:///service_cyrusimap/imapd.annotation_definitions_${template_imapd}",
      mode    => 640,
      owner => 'cyrus',
      group => 'mail',
#      notify  => Service['cyrus-imapd'],
      require => Package['cyrus-imapd'];
  }

#   service { 'cyrus-imapd':
#     ensure    => 'running',
#     enable    => true,
#     require => Package['cyrus-imapd'];
#   }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/cyrus-imapd':
        ensure => '/etc/init.d/cyrus-imapd',
        require  => Package['cyrus-imapd']
      }
    }
  }
}
