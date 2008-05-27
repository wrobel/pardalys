import 'os_gentoo'

# Class service::spamassassin
#  Defines the configuration for the spamassassin service
#
# Parameters 
#
#  * operatingsystem: Defines the underlying operating system and
#    adapts the configuration accordingly.
#
#  * service_spamassassin_use_bayes: Should the bayes db be used?
#
#  * service_spamassassin_use_razor: Should razor be used?
#
#  * service_spamassassin_use_pyzor: Should pyzor be used?
#
#  * service_spamassassin_use_dcc: Should dcc be used?
#
#  * service_spamassassin_use_update: Should spamassassin
#    automatically fetch rule updates?
#
#  * service_spamassassin_amavisd: Is spamassassin a subprocess of
#    amavisd-new?
#
#  * service_spamassassin_amavisd_bayes: Location of the bayes db when
#    using spamassassin as subprocess to amavisd-new
#
# Templates
#
#  * templates/bayes.cf: Basic configuration for the bayes features of
#    spamassassin.
#
#  * templates/sa-update: Cron script for updating the spamassassin
#    rules.
#
class service::spamassassin {
  # Package preparations
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { spamassassin:
        context => 'service_spamassassin',
        package => 'mail-filter/spamassassin',
        use     => 'berkdb doc ssl'
      }
    }
  }
  
  # Package installation
  package { spamasassin:
    name     => 'spamassassin',
    category => $operatingsystem ? {
      gentoo  => 'mail-filter',
      # Still undefined for all other OS
      default => ''
    },
    ensure   => 'installed',
    require  => $operatingsystem ? {
      gentoo => Gentoo_use_flags['spamassassin']
    }
  }

  # Possible configuration
  if $service_spamassassin_use_bayes {
    file { 'service_spamassassin_bayes':
      path    => '/etc/spamassassin/bayes.cf',
      content => template('service_spamassassin/bayes.cf'),
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      require => Package['spamassassin']
    }
  }

  if $service_spamassassin_use_dcc {
    package { dcc:
      name     => 'dcc',
      category => $operatingsystem ? {
        gentoo  => 'mail-filter',
        # Still undefined for all other OS
        default => ''
      },
      ensure   => 'installed'
    }

    file { 'service_spamassassin_dcc':
      path    => '/etc/spamassassin/dcc.cf',
      content => 'use_dcc 1',
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      require => [Package['spamassassin'], Package['dcc']]
    }
  }

  if $service_spamassassin_use_pyzor {
    package { pyzor:
      name     => 'pyzor',
      category => $operatingsystem ? {
        gentoo  => 'dev-python',
        # Still undefined for all other OS
        default => ''
      },
      ensure   => 'installed'
    }

    file { 'service_spamassassin_pyzor':
      path    => '/etc/spamassassin/pyzor.cf',
      content => 'use_pyzor 1',
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      require => [Package['spamassassin'], Package['pyzor']]
    }

    if $service_spamassassin_amavisd {
      exec { pyzor_discover:
        path => "/usr/bin:/usr/sbin:/bin",
        command => "su -s /bin/bash - amavis -c \"pyzor discover\"",
        require => Package['amavisd-new'],
        unless => "test -e /var/amavis/.pyzor/servers"
      }
    } else {
      exec { pyzor_discover:
        path => "/usr/bin:/usr/sbin:/bin",
        command => "pyzor -homedir /etc/mail/spamassassin/.pyzor discover ",
        require => Package['spamassassin'],
        unless => "test -e /etc/mail/spamassassin/.pyzor/servers"
      }
    }
  }

  if $service_spamassassin_use_razor {
    package { razor:
      name     => 'razor',
      category => $operatingsystem ? {
        gentoo  => 'mail-filter',
        # Still undefined for all other OS
        default => ''
      },
      ensure   => 'installed',
    }

    file { 'service_spamassassin_razor':
      path    => '/etc/spamassassin/razor.cf',
      content => 'use_razor2 1',
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      require => [Package['spamassassin'], Package['razor']]
    }

    if $service_spamassassin_amavisd {
      exec { razor_register:
        path => "/usr/bin:/usr/sbin:/bin",
        command => "su -s /bin/bash - amavis -c \"razor-admin -create && su -s /bin/bash - amavis -c \"razor-admin -register -user $sysadmin_user\"",
        require => Package['amavisd-new'],
        unless => "test -e /var/amavis/.razor/identity"
      }
    } else {
      exec { razor_register:
        path => "/usr/bin:/usr/sbin:/bin",
        command => "razor-admin -create -home=/etc/mail/spamassassin/.razor && razor-admin -register -home=/etc/mail/spamassassin/.razor -user $sysadmin_user",
        require => Package['spamassassin'],
        unless => "test -e /etc/mail/spamassassin/.razor/identity"
      }
    }
  }

  if $service_spamassassin_use_update {

    file { 'service_spamassassin_update':
      path    => '/etc/cron.daily/sa-update',
      content => template('service_spamassassin/sa-update'),
      owner   => 'root',
      group   => 'root',
      mode    => 755,
      require => [Package['spamassassin']]
    }

  }
}
