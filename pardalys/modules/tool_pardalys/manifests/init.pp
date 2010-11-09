import 'os_gentoo'
import 'os_ubuntu'

# Class tool::pardalys
#
#  Provides the package installation for p@rdalys
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_pardalys
#
class tool::pardalys {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { ruby:
        context => 'tool_pardalys_ruby',
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
        context => 'tool_pardalys_ruby_ldap',
        package => 'dev-ruby/ruby-ldap',
        use     => 'ssl',
        require  => Package['openldap'],
      }
      package { ruby_ldap:
	name    => 'ruby-ldap',
        category => 'dev-ruby',
        ensure   => 'installed',
        require  => Gentoo_use_flags['ruby_ldap'],
        tag      => 'buildhost'
      }
      gentoo_use_flags { rake:
        context => 'tool_pardalys_rake',
        package => 'dev-ruby/rake',
        use     => 'doc',
        tag     => 'buildhost'
      }
      package { rake:
        category => 'dev-ruby',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['rake'],
        tag      => 'buildhost'
      }
      gentoo_use_flags { rspec:
        context => 'tool_pardalys_rspec',
        package => 'dev-ruby/rspec',
        use     => 'doc',
        tag     => 'buildhost'
      }
      package { rspec:
        category => 'dev-ruby',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['rspec'],
        tag      => 'buildhost'
      }
      gentoo_use_flags { mocha:
        context => 'tool_pardalys_mocha',
        package => 'dev-ruby/mocha',
        use     => 'doc',
        tag     => 'buildhost'
      }
      gentoo_keywords { mocha:
        context  => 'tool_pardalys_mocha',
        package  => '=dev-ruby/mocha-0.9.9',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { mocha:
        category => 'dev-ruby',
        ensure   => 'installed',
        require  =>  [ Gentoo_keywords['mocha'],
                       Gentoo_use_flags['mocha'] ],
        tag      => 'buildhost'
      }
      gentoo_keywords { facter:
        context  => 'tools_pardalys_facter',
        package  => '<=dev-ruby/facter-1.5.2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_keywords { puppet:
        context  => 'tools_puppet_common_puppet',
        package  => '=app-admin/puppet-0.24.5-r4',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_use_flags { puppet:
        context => 'tool_pardalys_puppet',
        package => 'app-admin/puppet',
        use     => 'emacs ldap'
      }
      package { puppet:
        category => 'app-admin',
        ensure   => 'installed',
        tag      => 'buildhost',
        require => [ Gentoo_use_flags['puppet'],
                     Gentoo_keywords['puppet'],
                     Gentoo_keywords['facter']]
      }
      gentoo_use_flags { git:
        context => 'tool_pardalys_git',
        package => 'dev-vcs/git',
        use     => 'emacs bash-completion',
        tag     => 'buildhost'
      }
      package { git:
        category => 'dev-vcs',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['git'],
        tag      => 'buildhost'
      }
      # As the tool will be in development for a while we don't add a
      # version restriction for now
      gentoo_keywords { pardalys:
        context  => 'tool_pardalys_pardalys',
        package  => 'app-admin/pardalys',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_use_flags { pardalys:
        context => 'tool_pardalys_pardalys',
        package => 'app-admin/pardalys',
        use     => 'develop',
        tag     => 'buildhost'
      }
      package { pardalys:
        category => 'app-admin',
        ensure   => 'installed',
        require  =>  [Gentoo_keywords['pardalys'],
                      Gentoo_use_flags['pardalys']],
        tag      => 'buildhost'
      }
    }
    ubuntu:
    {
      include ubuntu::repositories::pardus

      realize File[pardus_list]

      package { puppet-el: ensure => 'installed' }
      package { pardalys: ensure => 'installed' }
      package { git-core: ensure => 'installed' }
      package { rake: ensure => 'installed' }
      package { rubygems: ensure => 'installed' }
      package { libmocha-ruby: ensure => 'installed' }
      package { librspec-ruby: ensure => 'installed' }
      package { 'libldap-ruby1.8': ensure => 'installed' }

      $pardalys_os = 'ubuntu'
    }
    default:
    {
      package { puppet-el: ensure => 'installed' }
      package { pardalys: ensure => 'installed' }
      package { git-core: ensure => 'installed' }
      package { rake: ensure => 'installed' }
      package { rubygems: ensure => 'installed' }
      package { libmocha-ruby: ensure => 'installed' }
      package { librspec-ruby: ensure => 'installed' }
      package { 'libldap-ruby1.8': ensure => 'installed' }
    }
  }

  file { 
    '/etc/pardalys':
    ensure  => 'directory';
  }

  $pardalys_type =  get_var('pardalys_type', 'plain')

  case $pardalys_type {
    'slave': {

      $pardalys_modules =  get_var('pardalys_modules', 'meta_kolab_complete')
      $my_pardalys_modules =  split($pardalys_modules, ',')

      $pardalys_ldapserver = get_var('ldap_host')
      $pardalys_ldapbase = get_var('base_dn')
      $pardalys_ldapuser = get_var('bind_dn_nobody')
      $pardalys_ldappass = get_var('bind_pw_nobody')

      file { 
        '/etc/pardalys/site.pp':
        content  => template('tool_pardalys/site.pp'),
        require  => File['/etc/pardalys'];
      }
    }
    'local': {
      $pardalys_ldapserver = ''
      $pardalys_ldapbase = ''
      $pardalys_ldapuser = ''
      $pardalys_ldappass = ''
    }
  }

  file { 
    '/etc/pardalys/puppet.conf':
    content  => template('tool_pardalys/puppet.conf'),
    require  => File['/etc/pardalys'];
  }

}
