import 'os_gentoo'

# Class tool::portage
#  Provides some common portage tools
#
# Required parameters 
#
#  * sysadmin :
#
#  * mailserver :
#
#  * hostname :
#
#  * domainname :
#
# Optional parameters 
#
#  * :
#
# Templates
#
#  * templates/make.conf_*: Main portage configuration.
#
class tool::portage {

  gentoo_use_flags { eselect:
    context => 'tools_portage_common_eselect',
    package => 'app-admin/eselect',
    use     => 'doc bash-completion',
    tag     => 'buildhost'
  }
  gentoo_use_flags { portage:
    context => 'tools_portage_common_portage',
    package => 'sys-apps/portage',
    use     => 'doc epydoc',
    tag     => 'buildhost'
  }
  package { 
    ['esearch', 'euses', 'gentoolkit', 'gentoolkit-dev', 'mirrorselect',
    'portage-utils', 'pybugz']:
    ensure   => 'installed',
    tag      => 'buildhost';
    'eselect':
    category => 'app-admin',
    ensure   => 'installed',
    require  => Gentoo_use_flags['eselect'],
    tag      => 'buildhost';
    'portage':
    category => 'sys-apps',
    ensure   => 'installed',
    require  => Gentoo_use_flags['portage'],
    tag      => 'buildhost';
  }

  $template_version = template_version($version_portage, '2.1.4.4@:2.1.4.4,')

  $profile              = get_var('portage_profile',             '/usr/portage/profiles/default-linux/x86/2007.0')
  $use                  = get_var('portage_use',                  false)
  $chost                = get_var('portage_chost',                'i686-pc-linux-gnu')
  $cflags               = get_var('portage_cflags',               false)
  $accept_keywords      = get_var('portage_accept_keywords',      false)
  $logdir               = get_var('portage_logdir',               false)
  $dispatch_conf_logdir = get_var('portage_dispatch_conf_logdir', false)
  $overlays             = split(get_var('portage_overlays'), ',')
  $fetch_command        = get_var('portage_fetch_command',        false)
  $mirrors              = split(get_var('portage_mirrors'), ',')
  $rsync_mirror         = get_var('portage_rsync_mirror',         ',')
  $binhost              = get_var('portage_binhost',              false)
  $rsync_includes       = split(get_var('portage_rsync_includes'), ',')
  $rsync_exclude        = get_var('portage_rsync_exclude',        false)
  $emerge_opts          = get_var('portage_emerge_opts',          false)
  $make_opts            = get_var('portage_make_opts',            false)
  $features             = split(get_var('portage_features'), ',')
  $input_devices        = split(get_var('portage_input_devices'), ',')
  $video_devices        = split(get_var('portage_video_devices'), ',')
  $config_protect       = split(get_var('portage_config_protect'), ',')
  $config_protect_mask  = split(get_var('portage_config_protect_mask'), ',')
  $linguas              = split(get_var('portage_linguas'), ',')
  $make_conf_add        = split(get_var('portage_make_conf_add'), ',')
  $monitor              = get_var('monitorhost',                  'localhost')

  if defined(Package['layman']) {
    $layman_storage = get_var('portage_layman_storage', false)
  } else {
    $layman_storage = false
  }

  if $logdir {
    file {'portage_logdir':
      path   => $logdir,
      ensure => 'directory',
      owner  => 'portage',
      group  => 'portage',
      tag    => 'buildhost'
    }
  }

  if $dispatch_conf_logdir {
    file {'dispatch_conf_logdir':
      path   => $dispatch_conf_logdir,
      ensure => 'directory',
      tag    => 'buildhost'
    }
  }

  if $rsync_exclude {
    file { $rsync_exclude:
      content => template("tool_portage/rsync_excludes_${template_version}"),
      require => Package['portage']
    }
  }

  # Portage configuration
  file {
    '/etc/make.profile':
    ensure  => $profile;
    '/etc/make.conf':
    content => template("tool_portage/make.conf_${template_version}"),
    require => Package['portage'],
    tag     => 'buildhost';
    '/etc/dispatch-conf.conf':
    content => template("tool_portage/dispatch-conf.conf_${template_version}"),
    require => Package['portage'],
    tag     => 'buildhost';
    '/etc/config-archive':
    ensure  => 'directory',
    tag     => 'buildhost';
    '/etc/cron.daily/eclean':
    source  => 'puppet:///tool_portage/eclean',
    mode    => 755;
    '/etc/cron.daily/esync':
    source  => 'puppet:///tool_portage/esync',
    mode    => 755;
    '/etc/cron.daily/glsa-check':
    content => template("tool_portage/glsa-check"),
    mode    => 755;
  }
}
