import 'os'
import 'os_gentoo'

define service::munin::plugin ($ensure = "present") {
  $plugin_path = "/etc/munin/plugins/$name"
  case $ensure {
    "absent": {
      file { $plugin_path:
        ensure => absent
      } 
    }
    default: {
      $plugin_src = $ensure ? { "present" => $name, default => $ensure }
      $plugin_src_path = "/usr/libexec/munin/plugins/$plugin_src"
      file { $plugin_path:
        ensure => "$plugin_src_path",
        require  => Package["munin"],
        notify => Service["munin-node"]
      }
    }
  }
}

# Class service::munin
#  Provides munin as a system monitor
#
# Required parameters 
#
#  * :
#
# Optional parameters 
#
#  * :
#
# Templates
#
#  * :
#
class service::munin {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { munin:
        context  => 'service_munin_munin',
        package  => 'net-analyzer/munin',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      gentoo_use_flags { munin:
        context => 'service_munin_munin',
        package => 'net-analyzer/munin',
        use     => 'doc',
        tag     => 'buildhost'
      }
      package { munin:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => [Gentoo_use_flags['munin'], Gentoo_keywords['munin']]
      }
    }
    default:
    {
    }
  }

  # Get the munin nodes we care for
  $munin_nodes = munin_nodes()

  $template_munin = template_version($version_munin, '1.3.3-r2@:1.3.3-r2,', '1.3.3-r2')

  # Munin node configuration
  file { 
    'service_munin_munin_node_conf':
    path    => '/etc/munin/munin-node.conf',
    content => template("service_munin/munin-node.conf_${template_munin}"),
    require => Package['munin'],
    notify => Service["munin-node"];
    '/usr/libexec/munin/plugins/load':
    source => 'puppet:///service_munin/load',
    require => Package['munin'],
    mode    => 755;
    '/usr/libexec/munin/plugins/processes':
    source => 'puppet:///service_munin/processes',
    require => Package['munin'],
    mode    => 755;
    '/usr/libexec/munin/plugins/netstat':
    source => 'puppet:///service_munin/netstat',
    require => Package['munin'],
    mode    => 755;
  }

  if defined(File['/etc/monit.d']) {
    file{
      '/etc/monit.d/munin-node':
      source => 'puppet:///service_munin/monit_munin-node';
    }
  }

  # Get the plugins that we should activate
  $my_munin_plugins = split($munin_plugins, ',')
  service::munin::plugin { $my_munin_plugins: }

  $my_munin_service_plugins = split($munin_service_plugins, ',')
  service::munin::plugin { $my_munin_service_plugins: }

  $my_munin_if = split($munin_if, ',')
  $my_munin_if_err = split($munin_if_err, ',')
  service::munin::plugin { $my_munin_if: ensure => "if_"}
  service::munin::plugin { $my_munin_if_err: ensure => "if_err_" }

  service { "munin-node":
    ensure => running,
    enable => true,
    require => Package['munin']
  }
}

class service::munin::master {

  # Get the munin nodes we care for
  $munin_nodes = munin_nodes()

  # Get the munin groups we have
  $my_munin_groups = split($munin_groups, ',')

  $template_munin = template_version($version_munin, '1.3.3-r2@:1.3.3-r2,', '1.3.3-r2')

  # Munin master configuration
  file { 'service_munin_munin_conf':
    path    => '/etc/munin/munin.conf',
    content => template("service_munin/munin.conf_${template_munin}"),
    require => Package['munin']
  }

  file { 
    '/etc/logwatch/scripts/services/munin-node':
    source  => 'puppet:///service_munin/logwatch_plugin_munin_node',
    require => Package['munin'];
    '/etc/logwatch/conf/services/munin-node.conf':
    source  => 'puppet:///service_munin/logwatch_plugin_munin_node.conf',
    require => Package['munin'];
  }

  # FIXME: The required munin cron job should be added.

  # Munin web configuration
  file { 'service_munin_lighttpd':
    path    => '/etc/lighttpd/munin.conf',
    content => template("service_munin/lighttpd_munin.conf"),
    require => Package['munin'],
    notify => Service["lighttpd"]
  }

}
