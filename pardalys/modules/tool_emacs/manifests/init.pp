import 'os_gentoo'

# Class tool::emacs
#
#  Installs emacs and some addon packages
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_emacs
#
class tool::emacs {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { mercurial:
        context => 'tools_emacs_mercurial',
        package => 'dev-util/mercurial',
        use     => 'emacs',
        tag     => 'buildhost'
      }
      gentoo_use_flags { gettext:
        context => 'tools_emacs_gettext',
        package => 'sys-devel/gettext',
        use     => 'emacs',
        tag     => 'buildhost'
      }
      gentoo_use_flags { autoconf:
        context => 'tools_emacs_autoconf',
        package => 'sys-devel/autoconf',
        use     => 'emacs',
        tag     => 'buildhost'
      }

      gentoo_use_flags { global:
        context => 'tool_emacs_global',
        package => 'dev-util/global',
        use     => 'doc emacs',
        tag     => 'buildhost'
      }
      gentoo_keywords { global:
        context  => 'tool_emacs_global',
        package  => '=dev-util/global-5.7.1',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { global:
        category => 'dev-util',
        ensure   => 'installed',
        require  =>  [Gentoo_use_flags['global'],
                      Gentoo_keywords['global']],
        tag      => 'buildhost'
      }
      gentoo_keywords { delicious:
        context  => 'tool_emacs_delicious',
        package  => '=app-emacs/delicious-0.3-r1',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { delicious:
        category => 'app-emacs',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['delicious'],
        tag      => 'buildhost'
      }
      package { elscreen:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      gentoo_keywords { ssh:
        context  => 'tool_emacs_ssh',
        package  => '=app-emacs/ssh-1.9',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { ssh:
        category => 'app-emacs',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['ssh'],
        tag      => 'buildhost'
      }
      package { gentoo-syntax:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { nxml-mode:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { po-mode:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      gentoo_keywords { php-mode:
        context  => 'tool_emacs_php_mode',
        package  => '=app-emacs/php-mode-1.4.0_beta',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { php-mode:
        category => 'app-emacs',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['php-mode'],
        tag      => 'buildhost'
      }
      gentoo_keywords { geben:
        context  => 'tool_emacs_geben',
        package  => '=app-emacs/geben-0.13',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { geben:
        category => 'app-emacs',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['geben'],
        tag      => 'buildhost'
      }
      package { python-mode:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { emacs-w3m:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { emacs:
        category => 'app-editors',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      file{
        '/usr/share/emacs/site-lisp/site-gentoo.d/72git-gentoo.el':
          source => 'puppet:///tool_emacs/72git-gentoo.el',
          tag      => 'buildhost';
        '/usr/share/emacs/site-lisp/php-mode/php-mode.el':
          source => 'puppet:///tool_emacs/php-mode.el_revision_70',
          tag      => 'buildhost';
      }

      exec {'refresh_site_dir':
        path => '/usr/bin:/usr/sbin:/bin',
        command => 'source /etc/init.d/functions.sh; source /usr/portage/eclass/elisp-common.eclass; elisp-site-regen',
        subscribe   => File['/usr/share/emacs/site-lisp/site-gentoo.d/72git-gentoo.el'],
        refreshonly => true;
      }

      $admin_fullname = get_var('admin_fullname', 'System Administrator')
      $admin_mail = get_var('admin_mail', 'root@localhost')

      $screen_dark = get_var('screen_dark', false)

      file{
        '/etc/skel/.emacs':
          content => template('tool_emacs/dot_emacs');
        '/etc/skel/.emacs.d':
          ensure => 'directory';
        '/etc/skel/.emacs.d/lisp':
          ensure => 'directory',
          require => File['/etc/skel/.emacs.d'];
        '/etc/skel/.emacs.d/00_emacs.el':
          source => 'puppet:///tool_emacs/ed_00_emacs.el',
          require => File['/etc/skel/.emacs.d'];
        '/etc/skel/.emacs.d/01_php_mode.el':
          source => 'puppet:///tool_emacs/ed_01_php_mode.el',
          require => File['/etc/skel/.emacs.d'];
        '/etc/skel/.emacs.d/97_env.el':
          source => 'puppet:///tool_emacs/ed_97_env.el',
          require => File['/etc/skel/.emacs.d'];
        '/etc/skel/.emacs.d/lisp/timer.el':
          source => 'puppet:///tool_emacs/el_timer.el',
          require => File['/etc/skel/.emacs.d/lisp'];
        '/etc/skel/.emacs.d/lisp/backup-each-save.el':
          source => 'puppet:///tool_emacs/el_backup-each-save.el',
          require => File['/etc/skel/.emacs.d/lisp'];
      }
    }
    default:
    {
      package { emacs:
        ensure   => 'installed',
      }
    }
  }
}
