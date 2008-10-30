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

  $ssl_cert    = get_var('ssl_cert', '')
  $ssl_key    = get_var('ssl_key', '')

  $ssl_cert_path = "${kolab_pki_dir}/server.crt"
  $ssl_key_path = "${kolab_pki_dir}/server.key"
  $ssl_combined_path = "${kolab_pki_dir}/server.pem"

  file { 
    "${kolab_pki_dir}":
    ensure => 'directory';
  }

  if $ssl_cert {
    file { 
      "${kolab_pki_dir}/server.crt":
        content => $ssl_cert,
        mode => '644',
        group => "$kolab_pki_grp",
        require => File["${kolab_pki_dir}"];
    }
  }
  if $ssl_key {
    file { 
      "${kolab_pki_dir}/server.key":
        content => $ssl_key,
        mode => '640',
        group => "$kolab_pki_grp",
        require => File["${kolab_pki_dir}"];
    }
    if $ssl_cert {
      file { 
        "${kolab_pki_dir}/server.pem":
          content => "$ssl_cert\n$ssl_key",
          mode => '640',
          group => "$kolab_pki_grp",
          require => File["${kolab_pki_dir}"];
      }
    }
  }
}
