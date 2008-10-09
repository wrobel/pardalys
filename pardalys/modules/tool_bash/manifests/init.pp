import 'os_gentoo'

# Class tool::bash
#
#  Bash configuration.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_bash
#
class tool::bash {

  # Package installation
  package { 
    'bash':
    ensure   => 'installed',
    tag      => 'buildhost';
    'coreutils':
    ensure   => 'installed',
    tag      => 'buildhost';
  }

  case $operatingsystem {
    gentoo:
    {
      package { 
        'gentoo-bashcomp':
        category => 'app-shells',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
    }
  }

  $template_bash = template_version($version_bash, '3.2_p17-r1@:3.2_p17-r1,', '3.2_p17-r1')
  $template_coreutils = template_version($version_coreutils, '6.10-r2@:6.10-r2,', '6.10-r2')

  $hostcolor = get_var('bash_hostcolor', 'NONE')

  file { 
    '/etc/bash/bash-interactive':
    content  => template("tool_bash/bash-interactive"),
    require => Package['bash'];
    '/etc/bash/bash-ls':
    source  => 'puppet:///tool_bash/bash-ls',
    require => Package['bash'];
    '/etc/bash/bash-prompt':
    source  => 'puppet:///tool_bash/bash-prompt',
    require => Package['bash'];
    '/etc/bash/bash-window':
    source  => 'puppet:///tool_bash/bash-window',
    require => Package['bash'];
    '/etc/bash/bashrc':
    source  => 'puppet:///tool_bash/bashrc',
    require => Package['bash'];
    '/etc/skel/.bashrc':
    source  => 'puppet:///tool_bash/dot_bashrc',
    require => Package['bash'];
    '/etc/skel/.bash_profile':
    source  => 'puppet:///tool_bash/dot_bash_profile',
    require => Package['bash'];
    '/etc/DIR_COLORS':
    source  => "puppet:///tool_bash/DIR_COLORS_${template_coreutils}";
    '/etc/skel/.bash-interactive':
    source  => 'puppet:///tool_bash/dot_bash_interactive',
    require => Package['bash'];
    '/etc/skel/.screenrc':
      source  => 'puppet:///tool_bash/dot_screenrc';
    '/usr/bin/grabssh':
      source  => 'puppet:///tool_bash/grabssh',
      mode => 755,
      require => Package['bash'];
  }
}
