import 'os_gentoo'

# Class service::amavisd_new
#
#  Defines the configuration for the amavisd_new mail filter
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_postfix
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
# @fact version_amavis   The amavisd-new version currently installed
#
# @fact kolab_fqdnhostname          Our primary Kolab hostname
# @fact kolab_local_addr            Our local IP (usually 127.0.0.1)
# @fact kolab_postfix_mydomain      Our primary mail domain
# @fact kolab_postfix_mynetworks    Networks that may relay through us
# @fact kolab_postfix_mydestination Our mail domains
# @fact amavisd_new_remote          Should we allow remote access to amavis?
# @fact amavisd_new_syslog          Should amavis log to syslog?
# @fact amavisd_new_remote_servers  Which remote servers may access amavis?
# @fact amavisd_new_language        Which template language should be used?
# @fact amavisd_new_quarantine      What quarantine method should be used?
# @fact amavisd_new_sa_local        Should spamassassin run only local tests?
# @fact amavisd_new_hostname        Alternative hostname if it should not
#                                   be kolab_fqdnhostname
#
class service::amavisd_new {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { amavisd_new:
        context => 'service_amavisd_new',
        package => 'mail-filter/amavisd-new',
        use     => 'mailwrapper nls'
      }
      package { 'amavisd-new':
        category => 'mail-filter',
        ensure   => 'installed',
        require  => Gentoo_use_flags['amavisd_new'],
        tag      => 'buildhost';
      }

      package { 'amavisd-new-templates':
        category => 'mail-filter',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'amavisd-new':
        ensure   => 'installed';
      }
      package { 'amavisd-new-templates':
        ensure   => 'installed';
      }
    }
  }

  # Initialize template variables
  $template_amavisd_new = template_version($version_amavis, '2.5.2@:2.5.2,', '2.5.2')

  $amavisd_new_rusr        = 'amavis'
  $amavisd_new_grp         = 'amavis'
  $amavisd_new_conf        = "${os::sysconfdir}/amavisd.conf"
  $amavisd_new_datadir     = "${os::localstatedir}/amavis"
  $amavisd_new_logfile     = "${amavisd_new_datadir}/amavis.log"
  $amavisd_new_templatedir = "${amavisd_new_datadir}/templates"
  $amavisd_new_quarantine_location = "${amavisd_new_datadir}/virusmails"

  $amavisd_new_remote         = get_var('amavisd_new_remote', false)
  $amavisd_new_syslog         = get_var('amavisd_new_syslog', true)
  $amavisd_new_remote_servers = split(get_var('amavisd_new_remote_servers'), ',')
  $amavisd_new_language       = get_var('amavisd_new_language', 'en_US')
  $amavisd_new_quarantine     = get_var('amavisd_new_quarantine', 'yes')
  $amavisd_new_sa_local       = get_var('amavisd_new_sa_local', true)

  $amavisd_new_hostname       = get_var('amavisd_new_hostname', false)

  $kolab_hostname = get_var('kolab_fqdnhostname')
  $local_addr = get_var('kolab_local_addr', '127.0.0.1')
  $postfixmydomain = get_var('kolab_postfix_mydomain')
  $postfixmydestination = get_var('kolab_postfix_mydestination')
  $postfixmynetworks = get_var('kolab_postfix_mynetworks')

  $bindir  = "${os::bindir}"
  $sbindir = "${os::sbindir}"

  # Configuration
  file { "${amavisd_new_conf}":
    content => template("service_amavisd_new/amavisd.conf_${template_amavisd_new}"),
    mode    => 640,
    notify  => Service['amavisd'],
    require => Package['amavisd-new']
  }

  service { 'amavisd':
    ensure    => 'running',
    enable    => true;
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/amavisd':
        ensure => '/etc/init.d/amavisd',
        require  => Package['amavisd-new']
      }
    }
  }

}
