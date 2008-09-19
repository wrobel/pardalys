import 'os_gentoo'

# Class tool::pardalys
#
#  Provides the package installation for p@rdalys
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
class tool::pardalys {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
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
        package  => '=dev-ruby/mocha-0.5.6',
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
      gentoo_use_flags { git:
        context => 'tool_pardalys_git',
        package => 'dev-util/git',
        use     => 'emacs bash-completion',
        tag     => 'buildhost'
      }
      package { git:
        category => 'dev-utils',
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
      package { pardalys:
        category => 'app-admin',
        ensure   => 'installed',
        require  =>  Gentoo_keywords['pardalys'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { pardalys:
        ensure   => 'installed',
      }
    }
  }

  $pardalys_type =  get_var('pardalys_type', 'plain')

  case $pardalys_type {
    slave: {

      $pardalys_modules =  get_var('pardalys_modules', 'meta_kolab_complete')
      $my_pardalys_modules =  split($pardalys_modules, ',')

      $pardalys_ldapserver = get_var('ldap_host')
      $pardalys_ldapbase = get_var('base_dn')
      $pardalys_ldapuser = get_var('bind_dn_nobody')
      $pardalys_ldappass = get_var('bind_pw_nobody')

      file { 
        '/etc/pardalys':
        ensure  => 'directory';
        '/etc/pardalys/site.pp':
        content  => template('tool_pardalys/site.pp'),
        require  => File['/etc/pardalys'];
        '/etc/pardalys/puppet.conf':
        content  => template('tool_pardalys/puppet.conf'),
        require  => File['/etc/pardalys'];
      }
    }
  }
}
