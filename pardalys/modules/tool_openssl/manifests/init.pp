import 'root'
import 'os_gentoo'

# Class tool::openssl
#
#  Provides SSL certificates for the system
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_openssl
#
# @module root           The root module is required to determine the installed
#                        SSL version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
#
class tool::openssl {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      package { 'openssl':
        category => 'dev-libs',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { 'openssl':
        ensure  => 'installed';
      }
    }
  }

  $ssl_confdir    = "${os::sysconfdir}/ssl"

  $ssl_cert    = get_var('ssl_cert', '')
  $ssl_key    = get_var('ssl_key', '')

  file { 
    "$ssl_confdir/system":
    ensure => 'directory';
  }

  if $ssl_cert {
    file { 
      "$ssl_confdir/system/server.crt":
      content => $ssl_cert;
    }
  }
  if $ssl_key {
    file { 
      "$ssl_confdir/system/server.key":
      content => $ssl_key,
      mode => '600';
    }
    if $ssl_cert {
      file { 
        "$ssl_confdir/system/server.pem":
        content => "$ssl_cert\n$ssl_key",
        mode => '600';
      }
    }
  }
}
