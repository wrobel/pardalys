import 'os_gentoo'

# Class service::amavisd_new
#  Defines the configuration for the amavisd_new mail filter
#
# Parameters 
#
#  * operatingsystem: Defines the underlying operating system and
#    adapts the configuration accordingly.
#
#  * sbindir: Path of admin tools.
#
#  * bindir: Path of normal executables.
#
#  * service_amavisd_new_remote: Is the amavis process getting
#    requests from other servers?
#
#  * service_amavisd_new_remote_servers: The remote machines that have
#    access to this amavisd machine
#
#  * service_amavisd_new_syslog: Should amavisd_new report to syslog?
#
#  * service_amavisd_new_sa_local: Should amavisd_new only use the
#    spamassassin local tests?
#
#  * service_amavisd_new_quarantine:
#     yes - amavisd_new quarantines mail
#     no  - amavisd_new passes mail defanged
#     ADMIN@EXAMPLE.COM  - amavisd_new passes mail to the given address
#
#  * service_amavisd_new_language: Identifies the language directory
#    for the templates under /etc/amavis/templates.
#    FIXME: Ensure this directory exists and holds templates.
#
# Templates
#
#  * templates/amavisd.conf_*: Configuration for the amavis service.
#
class service::amavisd_new {

  # Package preparations
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { amavisd_new:
        context => 'service_amavisd_new',
        package => 'mail-filter/amavisd-new',
        use     => 'mailwrapper nls'
      }
    }
  }
  
  # Package installation
  package { amavisd_new:
    name     => 'amavisd-new',
    category => $operatingsystem ? {
      gentoo  => 'mail-filter',
      # Still undefined for all other OS
      default => ''
    },
    ensure   => 'installed',
    require  => $operatingsystem ? {
      gentoo => Gentoo_use_flags['amavisd_new']
    }
  }

  package { amavisd_new_templates:
    name     => 'amavisd-new-templates',
    category => $operatingsystem ? {
      gentoo  => 'mail-filter',
      # Still undefined for all other OS
      default => ''
    },
    ensure   => 'installed',
  }

  # Initialize template variables

  # FIXME: This should be determined automatically
  $service_amavisd_new_version = $operatingsystem ? {
    gentoo  => '2.5.2',
    default => '2.5.2'
  }

  $service_amavisd_new_conf = $operatingsystem ? {
    gentoo  => '/etc/amavisd.conf',
    default => '/etc/amavisd.conf'
  }
  $service_amavisd_new_home = $operatingsystem ? {
    gentoo  => '/var/amavis',
    default => '/var/amavis'
  }
  $service_amavisd_new_rusr = $operatingsystem ? {
    gentoo  => 'amavis',
    default => 'amavis'
  }
  $service_amavisd_new_group = $operatingsystem ? {
    gentoo  => 'amavis',
    default => 'amavis'
  }
  $service_amavisd_new_logfile = $operatingsystem ? {
    gentoo  => '/var/amavis/amavis.log',
    default => '/var/amavis/amavis.log'
  }
  $service_amavisd_new_templatedir = $operatingsystem ? {
    gentoo  => '/var/amavis/templates',
    default => '/etc/amavis/templates'
  }
  $service_amavisd_new_quarantine_location = $operatingsystem ? {
    gentoo  => '/var/amavis/virusmails',
    default => '/var/amavis/virusmails'
  }

  # Rewrite the application version to the configuration version
  $amavisd_new_template_version = $service_amavisd_new_version ? {
    '2.5.2'  => '2.5.2'
  }

  $postfixmydomain = get_var('postfix_mydomain')
  $postfixmydestination = split(get_var('postfix_mydestination'), ',')
  $postfixmynetworks = get_var('postfix_mynetworks', '127.0.0.0/8')

  # Warn if we don't know the version
  # FIXME: This will only be useful once we know how to determine
  # package versions

  # Configuration
  file { 'service_amavisd_new_conf':
    path    => "${service_amavisd_new_conf}",
    content => template("service_amavisd_new/amavisd.conf_${amavisd_new_template_version}"),
    owner   => 'root',
    group   => 'root',
    mode    => 640,
    require => Package['amavisd_new']
  }

  service { 'service_amavisd_new_amavis' :
    name      => 'amavisd',
    ensure    => 'running',
    enable    => true,
    subscribe => File['service_clamav_freshclam_conf']
  }

}
