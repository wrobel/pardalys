import 'os_gentoo'

# Class service::dspam
#  Defines the configuration for the dspam mail filter. It only
#  configures a dspam installation controlled by amavis
#
# Parameters 
#
#  * operatingsystem: Defines the underlying operating system and
#    adapts the configuration accordingly.
#
# Templates
#
class service::dspam {

  # Package preparations
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { dspam:
        context => 'service_dspam',
        package => 'mail-filter/dspam',
        use     => 'sqlite syslog'
      }
    }
  }
  
  # Package installation
  package { dspam:
    name     => 'dspam',
    category => $operatingsystem ? {
      gentoo  => 'mail-filter',
      # Still undefined for all other OS
      default => ''
    },
    ensure   => 'installed',
    require  => $operatingsystem ? {
      gentoo => Gentoo_use_flags['dspam']
    }
  }

  # Initialize template variables

  # FIXME: This should be determined automatically
  $service_dspam_version = $operatingsystem ? {
    gentoo  => '3.8.0',
    default => '3.8.0'
  }

  $service_dspam_conf = $operatingsystem ? {
    gentoo  => '/etc/mail/dspam/dspam.conf',
    default => '/etc/mail/dspam/dspam.conf'
  }
  $service_dspam_home = $operatingsystem ? {
    gentoo  => '/var/amavis/dspam',
    default => '/var/amavis/dspam'
  }

  # Rewrite the application version to the configuration version
  $dspam_template_version = $service_dspam_version ? {
    '3.8.0'  => '3.8.0'
  }

  # Warn if we don't know the version
  # FIXME: This will only be useful once we know how to determine
  # package versions

  # Storage directory
  file { 'dspam::store::directory':
    path => '/var/amavis/dspam',
    ensure => 'directory',
    owner => 'amavis',
    group => 'amavis'
  }

  # Configuration
  file { 'service_dspam_conf':
    path    => "${service_dspam_conf}",
    content => template("service_dspam/dspam.conf_${dspam_template_version}"),
    owner   => 'root',
    group   => 'amavis',
    mode    => 640,
    require => Package['dspam']
  }

}
