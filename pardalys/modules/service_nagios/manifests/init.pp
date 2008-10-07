import 'os'
import 'os_gentoo'

# Class service::nagios
#  Provides nagios as a system nagiosor
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
class service::nagios {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { gd:
        context => 'service_nagios_gd',
        package => 'media-libs/gd',
        use     => 'fontconfig jpeg png truetype',
        tag     => 'buildhost'
      }
      package { gd:
        category => 'media-libs',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['gd']
      }

      gentoo_keywords { nagios-imagepack:
        context  => 'service_nagios_nagios_imagepack',
        package  => 'net-analyzer/nagios-imagepack',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      package { nagios-imagepack:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['nagios-imagepack']
      }

      gentoo_keywords { nagios-core:
        context  => 'service_nagios_nagios_core',
        package  => 'net-analyzer/nagios-core',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      gentoo_use_flags { nagios-core:
        context => 'service_nagios_nagios_core',
        package => 'net-analyzer/nagios-core',
        use     => 'lighttpd',
        tag     => 'buildhost'
      }
      package { nagios-core:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => [Gentoo_keywords['nagios-core'],Gentoo_use_flags['nagios-core']]
      }

      gentoo_keywords { nagios-nrpe:
        context  => 'service_nagios_nagios_nrpe',
        package  => 'net-analyzer/nagios-nrpe',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      package { nagios-nrpe:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['nagios-nrpe']
      }

      gentoo_keywords { nagios-plugins:
        context  => 'service_nagios_nagios_plugins',
        package  => 'net-analyzer/nagios-plugins',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      gentoo_use_flags { nagios-plugins:
        context => 'service_nagios_nagios_plugins',
        package => 'net-analyzer/nagios-plugins',
        use     => 'ldap nagios-ssh',
        tag     => 'buildhost'
      }
      package { nagios-plugins:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => [Gentoo_use_flags['nagios-plugins'], Gentoo_keywords['nagios-plugins']]
      }

      gentoo_keywords { nagios:
        context  => 'service_nagios_nagios',
        package  => 'net-analyzer/nagios',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      package { nagios:
        category => 'net-analyzer',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => [Gentoo_keywords['nagios']]
      }
    }
    default:
    {
      package { nagios:
        ensure   => 'installed'
      }
    }
  }

  define nagios_host() {
    $hostname  = nagios_hostname($name)
    $hostip    = nagios_hostip($name)
    $hostalias = nagios_hostalias($name)
    $hostgroup = nagios_hostgroup($name)
    file {
      "/etc/nagios/hosts/${hostname}.cfg":
        content => template( "service_nagios/host" ),
        notify  => Service['nagios']
    }
  }

  define nagios_service() {
    $servicename  = nagios_servicename($name)
    $servicehost  = nagios_servicehost($name)
    $servicedesc  = nagios_servicedesc($name)
    $servicecheck = nagios_servicecheck($name)
    file {
      "/etc/nagios/services/${servicename}.cfg":
        content => template( "service_nagios/service" ),
        notify  => Service['nagios']
    }
  }

  define nagios_ldap() {
    $hostname  = nagios_servicename($name)
    $base  = nagios_servicehost($name)
    file {
      "/etc/nagios/services/ldap_${hostname}.cfg":
        content => template( "service_nagios/ldap_service" ),
        notify  => Service['nagios']
    }
  }

  define nagios_default() {
    file {
      "/etc/nagios/services/sshd_${name}.cfg":
        content => template( "service_nagios/sshd_service" ),
        notify  => Service['nagios']
    }
    file {
      "/etc/nagios/services/load_${name}.cfg":
        content => template( "service_nagios/load_service" ),
        notify  => Service['nagios']
    }
    file {
      "/etc/nagios/services/df_${name}.cfg":
        content => template( "service_nagios/df_service" ),
        notify  => Service['nagios']
    }
    file {
      "/etc/nagios/services/netstat_${name}.cfg":
        content => template( "service_nagios/netstat_service" ),
        notify  => Service['nagios']
    }
    file {
      "/etc/nagios/services/processes_${name}.cfg":
        content => template( "service_nagios/processes_service" ),
        notify  => Service['nagios']
    }
    file {
      "/etc/nagios/services/glsa_${name}.cfg":
        content => template( "service_nagios/glsa_service" ),
        notify  => Service['nagios']
    }
  }

  $template_nagios = template_version($version_nagios, '3.0.1@:3.0.1,', '3.0.1')

  # Nagios configuration
  file { 
    '/etc/nagios/nagios.cfg':
    content => template("service_nagios/nagios.cfg_${template_nagios}"),
    mode    => 640,
    group   => 'nagios',
    require => Package['nagios'],
    notify  => Service["nagios"];
    '/etc/nagios/cgi.cfg':
    content => template("service_nagios/cgi.cfg_${template_nagios}"),
    mode    => 640,
    group   => 'nagios',
    require => Package['nagios'],
    notify  => Service["nagios"];
#     '/etc/nagios/nsca.cfg':
#     content => template("service_nagios/nsca.cfg_${template_nagios}"),
#     mode    => 640,
#     group   => 'nagios',
#     require => Package['nagios-nsca'],
#     notify  => Service["nsca"];
    '/etc/nagios/objects/commands.cfg':
    content => template("service_nagios/commands.cfg_${template_nagios}"),
    mode    => 640,
    group   => 'nagios',
    require => Package['nagios'],
    notify  => Service["nagios"];
    '/etc/nagios/objects/localhost.cfg':
    content => template("service_nagios/localhost.cfg_${template_nagios}"),
    mode    => 640,
    group   => 'nagios',
    require => Package['nagios'],
    notify  => Service["nagios"];
    '/etc/nagios/objects/templates.cfg':
    content => template("service_nagios/templates.cfg_${template_nagios}"),
    mode    => 640,
    group   => 'nagios',
    require => Package['nagios'],
    notify  => Service["nagios"];
    [ '/etc/nagios/hosts',
      '/etc/nagios/services' ]:
    ensure  => 'directory';
    '/etc/lighttpd/nagios.conf':
    content => template("service_nagios/lighttpd_nagios.conf"),
    require => Package['nagios'],
    notify  => Service['lighttpd'];
  }

  $hosts = split($nagios_hosts, ',')
  service::nagios::nagios_host { $hosts: }

  $services = split($nagios_services, ',')
  service::nagios::nagios_service { $services: }

  $default_services = split($nagios_default, ',')
  service::nagios::nagios_default { $default_services: }

  $ldap_services = split($nagios_ldap, ':')
  service::nagios::nagios_ldap { $ldap_services: }
      
  service { 'nagios':
    ensure => running,
    enable => true,
    require => Package['nagios']
  }

#   service { 'nsca':
#     ensure => running,
#     enable => true,
#     require => Package['nagios-nsca']
#   }

  case $operatingsystem {
    gentoo: {
      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/nagios':
        ensure => '/etc/init.d/nagios',
        require  => Package['nagios']
      }
    }
  }
}

