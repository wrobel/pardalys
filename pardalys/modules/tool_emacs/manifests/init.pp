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
        package => 'dev-vcs/mercurial',
        use     => 'emacs',
        tag     => 'buildhost'
      }
      gentoo_use_flags { ledger:
        context => 'tools_emacs_ledger',
        package => 'app-office/ledger',
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
    }
    default:
    {
      package { emacs: ensure => 'installed' }
      package { emacs-jabber: ensure => 'installed' }
      package { w3m-el: ensure => 'installed' }
    }
  }
}
