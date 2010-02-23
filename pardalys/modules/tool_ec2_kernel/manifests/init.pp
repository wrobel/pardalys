import 'root'
import 'os_gentoo'

# Class tool::ec2::kernel
#
#  Provides the kernel for a Xen instance on Amazons EC2
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_ec2_kernel
#
class tool::ec2::kernel {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      package { 'unifdef':
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      gentoo_use_flags { 'ec2-sources':
        context => 'tools_ec2_kernel_ec2_sources',
        package => 'sys-kernel/ec2-sources',
        use     => 'symlink',
        tag     => 'buildhost'
      }
      gentoo_keywords { 'ec2-sources':
        context  => 'tools_ec2_kernel_ec2_sources',
        package  => 'sys-kernel/ec2-sources',
        keywords => "~$keyword",
        tag      => 'buildhost';
      }
      gentoo_mask { 'udev':
        context => 'tools_ec2_kernel_udev',
        package => '>sys-fs/udev-124-r2',
        tag     => 'buildhost'
      }
      package { 'ec2-sources':
        ensure   => 'installed',
        tag      => 'buildhost',
        require => [Package['unifdef'],
                    Gentoo_use_flags['ec2-sources'],
                    Gentoo_keywords['ec2-sources']];
      }
    }
  }
  $template_ec2kernel = template_version($version_ec2kernel, '2.6.18@:2.6.18','2.6.18')

  $ec2_hardwaremodel = get_var('hardwaremodel', 'i686')
  $ec2_architecture  = get_var('architecture',  'i386')

  file {
    '/usr/src/linux/.config':
      source  => "puppet:///tool_ec2_kernel/dot_config_$ec2_architecture",
      ensure => 'present',
      replace => false,
      notify => Exec["ec2-sources-conf"],
      require => Package['ec2-sources'];
  }

  exec { "ec2-sources-conf":
    cwd => "/usr/src/linux",
    command => "/usr/bin/make oldconfig && \
                /usr/bin/make prepare && \
                /usr/bin/make headers_install",
    refreshonly => true,
    require => File['/usr/src/linux/.config'];
  }
  file { "/lib/modules":
    ensure => directory,
    before => Exec["ec2-modules-install"]
  }
  exec { "ec2-modules-install":
    command => "/usr/bin/wget -q -O - \
      http://s3.amazonaws.com/ec2-downloads/ec2-modules-$template_ec2kernel-xenU-ec2-v1.0-$ec2_hardwaremodel.tgz \
      | tar xzoC /",
    creates => "/lib/modules/$template_ec2kernel-xenU-ec2-v1.0",
    notify => Exec["ec2-modules-depmod"]
  }
  exec { "ec2-modules-depmod":
    command => "/sbin/depmod $template_ec2kernel-xenU-ec2-v1.0",
    refreshonly => true
  }

  @line {'kernel26_puppet_comment':
    file => '/etc/modules.d/kernel-2.6',
    line => '#This file gets automatically modified by puppet',
    tag => 'buildhost'
  }

  Line <| file == '/etc/modules.d/kernel-2.6' |>
}
