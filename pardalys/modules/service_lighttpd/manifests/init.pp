import 'os'
import 'os_gentoo'

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
class service::lighttpd {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { lighttpd:
        context => 'service_lighttpd_lighttpd',
        package => 'www-servers/lighttpd',
        use     => 'ipv6 pcre ssl bzip2 doc rrdtool',
        tag     => 'buildhost'
      }
      package { lighttpd:
        category => 'www-servers',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['lighttpd']
      }
    }
    default:
    {
    }
  }

  $template_lighttpd = template_version($version_portage, '1.4.19-r2@1.4.20@:1.4.19-r2,','1.4.19-r2')

  $my_lighttpd_modules = split($lighttpd_modules, ',')

  $my_lighttpd_users = split($lighttpd_users, ',')

  # Lighttpd master configuration
  file { 'service_lighttpd_lighttpd_conf':
    path    => '/etc/lighttpd/lighttpd.conf',
    content => template("service_lighttpd/lighttpd.conf_${template_lighttpd}"),
    require => Package['lighttpd'],
    notify => Service["lighttpd"]
  }

  # Lighttpd users
  file { 'service_lighttpd_users':
    path    => '/etc/lighttpd/htdigest.txt',
    content => template("service_lighttpd/htdigest.txt"),
    require => Package['lighttpd'],
    notify => Service["lighttpd"]
  }

  service { "lighttpd":
    ensure => running,
    enable => true,
    require => Package['lighttpd']
  }
}
