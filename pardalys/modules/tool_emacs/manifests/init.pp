import 'os_gentoo'

# Class tool::emacs
#
#  Installs emacs and some addon packages
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_pardalys
#
# @fact operatingsystem Allows to choose the correct package name
#                       depending on the operating system
# @fact keyword         The keyword for the system which is used to
#                       select unstable packages
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
        source => 'puppet:///tool_emacs/72git-gentoo.el';
      }

      $sysadmin_fullname = get_var('sysadmin_fullname', 'System Administrator')
      $sysadmin_mail = get_var('sysadmin_mail', 'root@localhost')

      file{'/root/.emacs':
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