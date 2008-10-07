import 'os_gentoo'

# Class tool::layman
#
#  Provides a setup for the layman overlay manager
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_layman
#
class tool::layman {

  # Layman is a Gentoo specific tool
  case $operatingsystem {
    gentoo:
    {
      package { 'layman':
        ensure   => 'installed',
        tag      => 'buildhost'
      }
  
      $template_layman = template_version($version_layman, '1.1.1@:1.1.1,', '1.1.1')

      $layman_storage = get_var('portage_layman_storage', '/usr/local/portage/layman')
      $rl = get_var('portage_layman_remote_lists', '')
      $layman_remote_lists = split($rl, ',')

      file { 
        '/etc/layman/layman.cfg':
        content => template("tool_layman/layman.cfg_${template_layman}"),
        require => Package['layman'],
        tag     => 'buildhost';
        '/etc/cron.daily/layman_update':
        source  => 'puppet:///tool_layman/layman_update',
        mode    => 755;
      }

      $overlays = split(get_var('portage_layman_overlays', ''), ',')

      overlay { $overlays:
        ensure  => 'installed',
        require => Package['layman'],
        tag     => 'buildhost';
      }
    }
  }
}
