import 'os_gentoo'

# Class service::clamav
#
#  Provides a configuration for the clamav virus scanner
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
# @fact version_clamav   The clamav version currently installed
# @fact clamav_syslog    Should clamav log to syslog?
#
class service::clamav {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { clamav:
        context => 'service_clamav',
        package => 'app-antivirus/clamav',
        use     => 'mailwrapper nls',
        tag     => 'buildhost'
      }
      package { 'clamav':
        category => 'app-antivirus',
        ensure   => 'installed',
        require  => Gentoo_use_flags['clamav'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { 'clamav':
        ensure   => 'installed';
      }
    }
  }

  # Initialize template variables
  $template_clamav = template_version($version_clamav, '0.93@:0.93,0.93.3@:0.93.3,', '0.93')

  $clamd_conf        = "${os::sysconfdir}/clamd.conf"
  $freshclam_conf    = "${os::sysconfdir}/freshclam.conf"
  $logdir            = "${os::logdir}/clamav"
  $clamd_logfile     = "${logdir}/clamd.log"
  $freshclam_logfile = "${logdir}/freshclam.log"
  $rundir            = "${os::sysrundir}/clamav"
  $clamd_pidfile     = "${rundir}/clamd.pid"
  $freshclam_pidfile = "${rundir}/freshclam.pid"

  $syslog            = get_var('clamav_syslog', true)
  $amavis_child      = get_var('amavis_child', true)

  if $amavis_child {
    $ruser   = 'amavis'
    $datadir = '/var/amavis/clamav'
    $socket  = '/var/amavis/clamd.sock'
    user {
      "$ruser":
        ensure     => 'present',
        provider => 'useradd',
        require => Package['amavisd-new'];
    }
  } else {
    $ruser   = 'clamav'
    $datadir = "${os::statelibdir}/clamav"
    $socket  = "${datadir}/clamd.sock"
  }


  file { "$logdir":
    ensure  => $syslog ? {
      false   => 'directory',
      'false' => 'directory',
      true    => 'absent',
      'true'  => 'absent'
    },
    owner   => $ruser,
    group   => $ruser
  }

  if $syslog {
    file { '/etc/logrotate.d/clamav':
      ensure  => 'absent',
    }
  }
  
  file {
    "$rundir":
    ensure => 'directory',
    owner   => $ruser,
    group   => $ruser,
    require => Package['clamav'];
    "$datadir":
    ensure => 'directory',
    owner   => $ruser,
    group   => $ruser,
    require => Package['clamav'];
    "$clamd_conf":
    content => template("service_clamav/clamd.conf_${template_clamav}"),
    owner   => 'root',
    group   => $ruser,
    mode    => 644,
    notify  => Service['clamd'],
    require => Package['clamav'];
    "$freshclam_conf":
    content => template("service_clamav/freshclam.conf_${template_clamav}"),
    owner   => 'root',
    group   => $ruser,
    mode    => 644,
    notify  => Service['clamd'],
    require => Package['clamav'];
  }

  service { 'clamd':
    ensure    => 'running',
    enable    => true,
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/clamd':
        ensure => '/etc/init.d/clamd',
        require  => Package['clamav']
      }
    }
  }

}
