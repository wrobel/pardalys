import 'root'
import 'os_gentoo'

# Class tool::fs
#
#  Provides tools for a variety of file systems.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_fs
#
class tool::fs {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { 's3fs':
        context  => 'tools_fs_s3fs',
        package  => 'sys-fs/s3fs',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
# FIXME: The fuse fs system need a decent kernel
#       package { 's3fs':
#         category => 'sys-fs',
#         ensure   => 'installed',
#         tag      => 'buildhost',
#         require  => Gentoo_Keywords['s3fs'];
#       }
      package { 'fuse':
        category => 'sys-fs',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      package { 'autofs':
        category => 'net-fs',
        ensure   => 'installed',
        tag      => 'buildhost';
      }

      @line {'kernel26_fuse':
        file => '/etc/modules.d/kernel-2.6',
        line => 'fuse',
        tag => 'buildhost'
      }

      @line {'kernel26_loop':
        file => '/etc/modules.d/kernel-2.6',
        line => 'loop',
        tag => 'buildhost'
      }
    }
  }

  $autofs_run_service = get_var('run_services', true)

  if $autofs_run_service {
    exec { "modprobe-fuse":
      command => "/sbin/modprobe fuse",
      unless => "/sbin/lsmod | grep fuse 1>/dev/null",
    }

    exec { "modprobe-loop":
      command => "/sbin/modprobe loop",
      unless => "/sbin/lsmod | grep loop 1>/dev/null",
    }

#     service { "autofs":
#       ensure => running,
#       enable => true,
#       require => Package['autofs']
#     }
  }
}
