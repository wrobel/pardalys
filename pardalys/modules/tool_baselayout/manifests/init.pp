import 'os_gentoo'

# Class tool::baselayout
#
#  Provides the baselayout configuration.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_baselayout
#
class tool::baselayout {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { baselayout:
        context  => 'tool_baselayout_baselayout',
        package  => '=sys-apps/baselayout-2.0.1',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_keywords { openrc:
        context  => 'tool_baselayout_openrc',
        package  => '=sys-apps/openrc-0.6.3',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 
        'udev':
        category => 'sys-fs',
        ensure   => 'latest',
        tag      => 'buildhost';
        'baselayout':
        category => 'sys-apps',
        ensure   => 'latest',
        require  => [Gentoo_keywords['baselayout'],  Gentoo_keywords['openrc']],
        tag      => 'buildhost';
        'openrc':
        category => 'sys-apps',
        ensure   => 'latest',
        require  => [Package['udev'], Package['baselayout'], Gentoo_keywords['openrc']],
        tag      => 'buildhost';
        'sysvinit':
        category => 'sys-apps',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
    }
  }

  $template_version = template_version($version_baselayout, '2.0.0@:2.0.0,', '2.0.0')

  $desktop = get_var('global_desktop', false)
  $override_virtual = get_var('override_virtual', false)
  $system_hostname     = get_var('hostname',   'localhost')
  $system_domainname   = get_var('domainname', 'localdomain')
  $ec2_hostname        = get_var('ec2_public_hostname',   false)
  $baselayout_fstab    = get_var('fstab', false)
  $baselayout_net      = get_var('net', false)
  $baselayout_timezone = get_var('timezone', false)

  if $override_virtual {
    $build_virtual = $override_virtual
  } else {
    $build_virtual = $virtual
  }

  file { 
    '/etc/hosts':
    content  => template("tool_baselayout/hosts"),
    require => Package['baselayout'];
    '/etc/conf.d/hostname':
    content  => template("tool_baselayout/hostname_${template_version}"),
    require => Package['openrc'];
    '/etc/inittab':
    content  => template("tool_baselayout/inittab"),
    require => Package['sysvinit'];
  }

  if $baselayout_fstab {
    file { 
      '/etc/fstab':
      content  => template("tool_baselayout/fstab"),
      require => Package['baselayout'];
    }
  }

  if $baselayout_timezone {
    file { 
      '/etc/timezone':
      content  => "$baselayout_timezone",
      require => Package['baselayout'];
    }
  }

  case $build_virtual {
    'openvz':
    {
      file { 
        '/etc/conf.d/net':
        content  => template("tool_baselayout/net_virtual_${template_version}"),
        require => Package['openrc'];
      }
    }
    'physical', 'xenu':
    {
      if $baselayout_net {
        file { 
          '/etc/conf.d/net':
          content  => template("tool_baselayout/net_real"),
          require => Package['openrc'];
        }
      }
    }
  }

  @line {'local_start_puppet_comment':
    file => '/etc/conf.d/local.start',
    line => '#This file gets automatically modified by puppet',
    tag => 'buildhost'
  }

  Line <| file == '/etc/conf.d/local.start' |>

  case $operatingsystem {
    gentoo: {
      file {
        '/etc/runlevels/boot/bootmisc':
        ensure => '/etc/init.d/bootmisc',
        require  => Package['openrc'];
        '/etc/runlevels/boot/hostname':
        ensure => '/etc/init.d/hostname',
        require  => Package['openrc'];
        '/etc/runlevels/boot/mtab':
        ensure => '/etc/init.d/mtab',
        require  => Package['openrc'];
        '/etc/runlevels/boot/nscd':
        ensure => '/etc/init.d/nscd',
        require  => Package['openrc'];
        '/etc/runlevels/default/local':
        ensure => '/etc/init.d/local',
        require  => Package['openrc'];
        '/etc/runlevels/default/net.lo':
        ensure => '/etc/init.d/net.lo',
        require  => Package['openrc'];
      }
      case $build_virtual {
        'physical', 'xenu':
        {
          file { 
            '/etc/runlevels/boot/consolefont':
            ensure => '/etc/init.d/consolefont',
            require  => Package['openrc'];
            '/etc/runlevels/boot/fsck':
            ensure => '/etc/init.d/fsck',
            require  => Package['openrc'];
            '/etc/runlevels/boot/hdparm':
            ensure => '/etc/init.d/hdparm',
            require  => Package['openrc'];
            '/etc/runlevels/boot/hwclock':
            ensure => '/etc/init.d/hwclock',
            require  => Package['openrc'];
            '/etc/runlevels/boot/keymaps':
            ensure => '/etc/init.d/keymaps',
            require  => Package['openrc'];
            '/etc/runlevels/boot/localmount':
            ensure => '/etc/init.d/localmount',
            require  => Package['openrc'];
            '/etc/runlevels/boot/modules':
            ensure => '/etc/init.d/modules',
            require  => Package['openrc'];
            '/etc/runlevels/boot/procfs':
            ensure => '/etc/init.d/procfs',
            require  => Package['openrc'];
            '/etc/runlevels/boot/root':
            ensure => '/etc/init.d/root',
            require  => Package['openrc'];
            '/etc/runlevels/boot/swap':
            ensure => '/etc/init.d/swap',
            require  => Package['openrc'];
            '/etc/runlevels/boot/sysctl':
            ensure => '/etc/init.d/sysctl',
            require  => Package['openrc'];
            '/etc/runlevels/boot/termencoding':
            ensure => '/etc/init.d/termencoding',
            require  => Package['openrc'];
            '/etc/runlevels/boot/urandom':
            ensure => '/etc/init.d/urandom',
            require  => Package['openrc'];
          }
          case $build_virtual {
            'physical':
            {
              file { 
                '/etc/runlevels/boot/numlock':
                ensure => '/etc/init.d/numlock',
                require  => Package['openrc'];
              }
            }
          }
        }
        'openvz':
        {
          file { 
            ['/etc/runlevels/boot/consolefont',
            '/etc/runlevels/boot/fsck',
            '/etc/runlevels/boot/hdparm',
            '/etc/runlevels/boot/hwclock',
            '/etc/runlevels/boot/keymaps',
            '/etc/runlevels/boot/localmount',
            '/etc/runlevels/boot/modules',
            '/etc/runlevels/boot/numlock',
            '/etc/runlevels/boot/procfs',
            '/etc/runlevels/boot/root',
            '/etc/runlevels/boot/swap',
            '/etc/runlevels/boot/sysctl',
            '/etc/runlevels/boot/termencoding',
            '/etc/runlevels/boot/urandom']:
            ensure  => 'absent',
            require => Package['openrc'];
            '/etc/init.d/net.venet0':
            ensure => '/etc/init.d/net.lo',
            require  => Package['openrc'];
            '/etc/runlevels/default/net.venet0':
            ensure => '/etc/init.d/net.venet0',
            require  => Package['openrc'];
          }
        }
      }
    }
  }
}
