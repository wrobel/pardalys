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

  $ssl_cert_path = ''
  $ssl_key_path = ''
  $ssl_combined_path = ''

  file { 
    "$ssl_confdir/system":
    ensure => 'directory';
  }

  if $ssl_cert {
    file { 
      "$ssl_confdir/system/server.crt":
      content => $ssl_cert;
    }
    $ssl_cert_path = "$ssl_confdir/system/server.crt"
  }
  if $ssl_key {
    file { 
      "$ssl_confdir/system/server.key":
      content => $ssl_key,
      mode => '600';
    }
    $ssl_key_path = "$ssl_confdir/system/server.key"
    if $ssl_cert {
      file { 
        "$ssl_confdir/system/server.pem":
        content => "$ssl_cert\n$ssl_key",
        mode => '600';
      }
      $ssl_combined_path = "$ssl_confdir/system/server.pem"
    }
  }
}
