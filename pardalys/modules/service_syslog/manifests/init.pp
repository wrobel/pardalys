import 'os_gentoo'

# Class service::syslog
#  Provides a configuration for the syslog-ng system
#
# Required parameters 
#
#  * service_syslog_remote_ip : If the syslog should be sent to a
#    remote IP this should hold the IP address
#
#  * service_syslog_remote_port : If the syslog should be sent to a
#    remote IP this should hold the remote port (default: 514)
#
#  * service_syslog_logrotate : Should the package provide logrotate
#    definitions?
#
# Optional parameters 
#
#  You can override additional internal variable with external global
#  variables.
#
# Templates
#
#  * templates/ : 
#
class service::syslog {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { 'syslog-ng':
        context => 'service_syslog_ng',
        package => 'app-admin/syslog-ng',
        use     => 'tcpd',
        tag     => 'buildhost'
      }
      package { 'syslog-ng':
        category => 'app-admin',
        ensure   => 'installed',
        require  => Gentoo_use_flags['syslog-ng'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { 'syslog-ng':
        ensure   => 'installed'
      }
    }
  }
  
  # Convert to template version
  $template_syslog_ng = template_version($version_syslog_ng, '2.0.6@2.0.9:2.0.6', '2.0.6')

  $remote_ip = get_var('service_syslog_remote_ip', false)
  $remote_port = get_var('service_syslog_remote_port', '514')
  $accept_remote = get_var('service_syslog_accept_remote', false)

  file { 
    '/var/log/syslog.d':
    ensure  => 'directory';
    '/etc/syslog-ng/syslog-ng.conf':
    content => template("service_syslog/syslog-ng.conf_${template_syslog_ng}"),
    require => Package['syslog-ng'],
    notify => Service['syslog-ng'];
    '/etc/logrotate.d/syslog-ng':
    content => template("service_syslog/logrotate.d_syslog_${template_syslog_ng}"),
    require => Package['syslog-ng'];
    '/etc/monit.d/syslog-ng':
    content => template("service_syslog/monit_syslog_ng");
    '/usr/libexec/munin/plugins/syslog_ng':
    source  => 'puppet:///service_syslog/munin_plugin_syslog_ng',
    mode    => 755;
#         '/etc/munin/plugins/syslog_ng':
#     ensure  => '/usr/libexec/munin/plugins/syslog_ng',
#     require => File['/usr/libexec/munin/plugins/syslog_ng'];
#     '/etc/munin/plugin-conf.d/syslog_ng':
#     source  => 'puppet:///service_syslog/munin_plugin_syslog_ng.conf';
  }

  if defined(Package['logwatch']) {
    file { 
      '/etc/logwatch/scripts/services/syslog-ng':
      source  => 'puppet:///service_syslog/logwatch_plugin_syslog_ng',
      require => Package['syslog-ng'];
      '/etc/logwatch/conf/services/syslog-ng.conf':
      source  => 'puppet:///service_syslog/logwatch_plugin_syslog_ng.conf',
      require => Package['syslog-ng'];
    }
  }

  service { 'syslog-ng':
    ensure    => 'running',
    enable    => true,
    require => Package['syslog-ng']
  }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/syslog-ng':
        ensure => '/etc/init.d/syslog-ng',
        require  => Package['syslog-ng']
      }
    }
  }
}
