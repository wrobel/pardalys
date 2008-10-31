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
      gentoo_use_flags { 'c-client':
        context => 'tool_php_c_client',
        package => 'net-libs/c-client',
        use     => 'kolab',
        tag     => 'buildhost'
      }
      package { 'c-client':
        category => 'net-libs',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['c-client'],
        tag      => 'buildhost'
      }
      #FIXME: Use "realize" here so that dependant packages can define required use flags
      gentoo_use_flags { php:
        context => 'tool_php_php',
        package => 'dev-lang/php',
        use     => 'apache2 bzip2 ctype ftp gd hash imap json kolab ldap mysql nls pcre reflection session spl sqlite tokenizer xml',
        tag     => 'buildhost'
      }
      package { php:
        category => 'dev-lang',
        ensure   => 'installed',
        require  =>  [Gentoo_use_flags['php'],
                      Package['c-client']],
        tag      => 'buildhost'
      }

      package { php-docs:
        category => 'app-doc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { xdebug:
        category => 'dev-php5',
        ensure   => 'installed',
        require  =>  Package['php'],
        tag      => 'buildhost'
      }

      gentoo_keywords { 'PEAR-CodeSniffer':
        context  => 'tool_php_pear_codesniffer',
        package  => '=dev-php/PEAR-CodeSniffer-1.1.0',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'PEAR-CodeSniffer':
        category => 'dev-php',
        ensure   => 'installed',
        require  =>  [Package['php'],
                      Gentoo_keywords['PEAR-CodeSniffer']],
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
