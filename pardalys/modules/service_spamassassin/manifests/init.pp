import 'os_gentoo'

# Class service::spamassassin
#
#  Defines the configuration for the spamassassin service
#
# Parameters 
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_spamassassin
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
# @fact version_spamassassin   The spamassassin version currently installed
#
class service::spamassassin {

  $use_bayes  = get_var('spamassassin_use_bayes', true)
  $use_dcc    = get_var('spamassassin_use_dcc', true)
  $use_pyzor  = get_var('spamassassin_use_pyzor', true)
  $use_razor  = get_var('spamassassin_use_razor', true)
  $use_update = get_var('spamassassin_use_update', true)

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      if $use_dcc {
        package { 'dcc':
          category => 'mail-filter',
          ensure   => 'installed'
        }
      }

      if $use_pyzor {
        package { 'pyzor':
          category => 'dev-python',
          ensure   => 'installed'
        }
      }

      if $use_razor {
        package { 'razor':
          category => 'mail-filter',
          ensure   => 'installed'
        }
      }

      gentoo_use_flags { spamassassin:
        context => 'service_spamassassin',
        package => 'mail-filter/spamassassin',
        use     => 'berkdb doc ssl'
      }
      package { 'spamassassin':
        category => 'mail-filter',
        ensure   => 'installed',
        require  => Gentoo_use_flags['spamassassin'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { 'spamassassin':
        ensure   => 'installed';
      }
    }
  }

  $amavis_child      = get_var('amavis_child', true)
  $amavis_sysadmin = get_var('kolab_admin_mail', 'root@localhost')

  # Possible configuration
  if $service_spamassassin_use_bayes {
    file { 'service_spamassassin_bayes':
      path    => '/etc/spamassassin/bayes.cf',
      content => template('service_spamassassin/bayes.cf'),
      require => Package['spamassassin']
    }
  }

  if $use_dcc {
    file { '/etc/spamassassin/dcc.cf':
      content => 'use_dcc 1',
      require => [Package['spamassassin'], Package['dcc']]
    }
  }

  if $use_pyzor {
    file { '/etc/spamassassin/pyzor.cf':
      content => 'use_pyzor 1',
      require => [Package['spamassassin'], Package['pyzor']]
    }
  }

  if $use_razor {
    file { '/etc/spamassassin/razor.cf':
      content => 'use_razor2 1',
      require => [Package['spamassassin'], Package['razor']]
    }
  }

  if $amavis_child {
    exec { pyzor_discover:
      path => "/usr/bin:/usr/sbin:/bin",
      command => "su -s /bin/bash - amavis -c \"pyzor discover\"",
      require => [Package['amavisd-new'], Package['pyzor']],
      unless => "test -e /var/amavis/.pyzor/servers"
    }
  } else {
    exec { pyzor_discover:
      path => "/usr/bin:/usr/sbin:/bin",
      command => "pyzor -homedir /etc/mail/spamassassin/.pyzor discover ",
      require => [Package['spamassassin'], Package['pyzor']],
      unless => "test -e /etc/mail/spamassassin/.pyzor/servers"
    }
  }

  if $amavis_child {
    exec { razor_register:
      path => "/usr/bin:/usr/sbin:/bin",
      command => "su -s /bin/bash - amavis -c \"razor-admin -create\" && su -s /bin/bash - amavis -c \"razor-admin -register -user $amavis_sysadmin\"",
      require => [Package['amavisd-new'], Package['razor']],
      unless => "test -e /var/amavis/.razor/identity"
    }
  } else {
    exec { razor_register:
      path => "/usr/bin:/usr/sbin:/bin",
      command => "razor-admin -create -home=/etc/mail/spamassassin/.razor && razor-admin -register -home=/etc/mail/spamassassin/.razor -user $amavis_sysadmin",
      require => [Package['spamassassin'], Package['razor']],
      unless => "test -e /etc/mail/spamassassin/.razor/identity"
    }
  }

  if $use_update {
    file {'/etc/cron.daily/sa-update':
      content => template('service_spamassassin/sa-update'),
      mode    => 755,
      require => [Package['spamassassin']]
    }
  }
}
