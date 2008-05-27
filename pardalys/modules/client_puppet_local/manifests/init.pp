import 'os_gentoo'
import 'service_openldap'

import 'service_openldap'

# Class client::puppet::local
#  Prepares a basic puppet installatin that knows how to contact 
#  a LDAP server
#
# Parameters 
#
#  * operatingsystem: Defines the underlying operating system and
#    adapts the configuration accordingly.
#
# Templates
#
class client::puppet::local {

  # Package preparations
  case $operatingsystem {
    gentoo:
    {
      include service::openldap

      gentoo_use_flags { ruby:
        context => 'client_puppet_local_ruby',
        package => 'dev-lang/ruby',
        use     => 'cgi gdbm berkdb ipv6 doc ssl examples emacs threads'
      }
      package { ruby:
        category => 'dev-lang',
        ensure   => 'installed',
        require  => Gentoo_use_flags['ruby'],
        tag      => 'buildhost'
      }

      gentoo_use_flags { ruby_ldap:
        context => 'client_puppet_local_ruby_ldap',
        package => 'dev-ruby/ruby-ldap',
        use     => 'ssl'
      }
      package { ruby_ldap:
	name    => 'ruby-ldap',
        category => 'dev-ruby',
        ensure   => 'installed',
        require  => Gentoo_use_flags['ruby_ldap'],
        tag      => 'buildhost'
      }

      gentoo_keywords { puppet:
        context  => 'tools_puppet_common_puppet',
        package  => '<=app-admin/puppet-0.24.4-r1',
        keywords => "~$arch",
        tag      => 'buildhost'
      }
      gentoo_use_flags { puppet:
        context => 'client_puppet_local_puppet',
        package => 'app-admin/puppet',
        use     => 'emacs sqlite doc'
      }
      package { puppet:
        category => 'app-admin',
        ensure   => 'installed',
        tag      => 'buildhost',
        require => [ Gentoo_use_flags['puppet'], Gentoo_keywords['puppet'] ]
      }

      gentoo_use_flags { mercurial:
        context => 'tools_puppet_common_mercurial',
        package => 'dev-util/mercurial',
        use     => 'bash-completion emacs gpg subversion',
        tag     => 'buildhost'
      }
      package { mercurial:
        category => 'dev-util',
        ensure   => 'installed',
        require  => Gentoo_use_flags['mercurial'],
        tag      => 'buildhost'
      }
    }
  }

}
