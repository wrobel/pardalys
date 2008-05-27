import 'os_gentoo'

# Class service::clamav
#  Provides a configuration for the clamav virus scanner
#
# Required parameters 
#
#  * service_clamav_amavis: Is clamav running as subprocess to amavis?
#
#  * service_clamav_syslog: Should clamav report to syslog?
#
# Optional parameters 
#
#  You can override additional internal variable with external global
#  variables.
#
# Templates
#
#  * templates/clamd.conf_*: Configuration for the clamd service.
#
#  * templates/freshclam.conf_*: Configuration for the freshclam service.
#
class service::clamav {

  $ruser = $operatingsystem ? {
    gentoo  => $service_clamav_amavis ? {
      yes => 'amavis',
      no  => 'clamav'
    },
    default => 'clamav'
  }

  if $service_clamav_clamd_conf {
    $clamd_conf = $service_clamav_clamd_conf
  } else {
    $clamd_conf = $operatingsystem ? {
      gentoo  => '/etc/clamd.conf',
      default => '/etc/clamd.conf'
    }
  }
  if $service_clamav_freshclam_conf {
    $clamd_conf = $service_clamav_freshclam_conf
  } else {
    $freshclam_conf = $operatingsystem ? {
      gentoo  => '/etc/freshclam.conf',
      default => '/etc/freshclam.conf'
    }
  }

  if $service_clamav_logdir {
    $logdir = $service_clamav_logdir
  } else {
    $logdir =  $operatingsystem ? {
      gentoo  => '/var/log/clamav',
      default => '/var/log/clamav'
    }
  }

  if $service_clamav_clamd_logfile {
    $clamd_logfile = $service_clamav_clamd_logfile
  } else {
    $clamd_logfile = $operatingsystem ? {
      gentoo  => '${logdir}/clamd.log',
      default => '${logdir}/clamd.log'
    }
  }

  if $service_clamav_freshclam_logfile {
    $freshclam_logfile = $service_clamav_freshclam_logfile
  } else {
    $freshclam_logfile = $operatingsystem ? {
      gentoo  => '${logdir}/freshclam.log',
      default => '${logdir}/freshclam.log'
    }
  }

  if $service_clamav_rundir {
    $rundir = $service_clamav_rundir
  } else {
    $rundir =  $operatingsystem ? {
      gentoo  => '/var/run/clamav',
      default => '/var/run/clamav'
    }
  }
  $clamd_pidfile = $operatingsystem ? {
    gentoo  => '${rundir}/clamd.pid',
    default => '${rundir}/clamd.pid'
  }
  $freshclam_pidfile = $operatingsystem ? {
    gentoo  => '${rundir}/freshclam.pid',
    default => '${rundir}/freshclam.pid'
  }

  if $service_clamav_socket {
    $socket = $service_clamav_socket
  } else {
    $socket = $operatingsystem ? {
      gentoo  => $service_clamav_amavis ? {
        no  =>'${rundir}/clamd.sock',
	yes =>'/var/amavis/clamd.sock'
      },
      default => '${rundir}/clamd.sock'
    }
  }

  if $service_clamav_datadir {
    $datadir = $service_clamav_datadir
  } else {
    $datadir = $operatingsystem ? {
      gentoo  => $service_clamav_amavis ? {
        no  =>'/var/lib/clamav',
	yes =>'/var/amavis/clamav'
      },
      default => '/var/lib/clamav'
    }
  }

  $syslog = $service_clamav_syslog

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
      package { clamav:
        name     => 'clamav',
        category => 'app-antivirus',
        ensure   => 'installed',
        require  => Gentoo_use_flags['clamav'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { clamav:
        name     => 'clamav',
        ensure   => 'installed',
      }
    }
  }
  
  # FIXME: This should be determined automatically
  $service_clamav_version = $operatingsystem ? {
    gentoo  => '0.92.1',
    default => '0.92.1'
  }

  # Rewrite the application version to the configuration version
  # Warn if we don't know the version
  # FIXME: This will only be useful once we know how to determine
  # package versions
  $clamd_template_version = $service_clamav_version ? {
    '0.92.1' => '0.92.1'
  }

  case $syslog {
    no: 
    {
      file { 'service_clamav_logdir':
        path    => $logdir,
        ensure  => 'directory',
        owner   => $ruser,
        group   => $ruser
      }
    }
    yes: 
    {
      file { 'service_clamav_logdir':
        path   => $logdir,
        ensure => 'absent',
        force  => true
      }
    }
  }

  file {'service_clamav_rundir':
    path => $rundir,
    ensure => 'directory',
    owner   => $ruser,
    group   => $ruser
  }

  file {'service_clamav_datadir':
    path => $datadir,
    ensure => 'directory',
    owner   => $ruser,
    group   => $ruser
  }

  # Configuration
  file { 'service_clamav_clamd_conf':
    path    => $clamd_conf,
    content => template("service_clamav/clamd.conf_${clamd_template_version}"),
    owner   => 'root',
    group   => $ruser,
    mode    => 644,
    require => Package['clamav']
  }

  file { 'service_clamav_freshclam_conf':
    path    => $freshclam_conf,
    content => template("service_clamav/freshclam.conf_${clamd_template_version}"),
    owner   => 'root',
    group   => $ruser,
    mode    => 644,
    require => Package['clamav']
  }

  service { 'service_clamav_clamd' :
    name      => 'clamd',
    ensure    => 'running',
    enable    => true,
    subscribe => File['service_clamav_clamd_conf']
  }

}
