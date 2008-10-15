import 'os_gentoo'

# Class tool::php
#
#  Provides some basic php tools
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_php
#
class tool::php {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { php:
        context => 'tool_php_php',
        package => 'dev-lang/php',
        use     => 'kolab imap ldap nls session xml apache2 ctype ftp gd json sqlite tokenizer spl pcre reflection bzip2 mysql',
        tag     => 'buildhost'
      }
      package { php:
        category => 'dev-lang',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['php'],
        tag      => 'buildhost'
      }

      package { xdebug:
        category => 'dev-php5',
        ensure   => 'installed',
        require  =>  Package['php'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { php:
        ensure   => 'installed',
      }
    }
  }
}
