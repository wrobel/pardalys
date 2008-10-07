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
      gentoo_use_flags { global:
        context => 'tool_emacs_global',
        package => 'dev-util/global',
        use     => 'doc emacs',
        tag     => 'buildhost'
      }
      package { global:
        category => 'dev-util',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['global'],
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
      package { php-mode:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { python-mode:
        category => 'app-emacs',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { emacs:
        category => 'app-editors',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      file{'/usr/share/emacs/site-lisp/site-gentoo.d/72git-gentoo.el':
        source => 'puppet:///tool_emacs/72git-gentoo.el',
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

      file{'/etc/skel/.emacs':
        content => template('tool_emacs/dot_emacs');
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
