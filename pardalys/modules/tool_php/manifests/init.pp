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
        use     => 'apache2 bzip2 ctype filter ftp gd hash imap json kolab ldap mysql nls pcre reflection session simplexml soap spl sqlite tokenizer xml',
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
        tag      => 'buildhost',
        notify   => Exec['rebuild_completions'];
      }

      file { '/usr/bin/php_completions.sh' :
        source   => 'puppet:///tool_php/php_completions.sh',
        mode     => '755',
        require  => Package['php-docs'];
      }

      exec { "rebuild_completions":
        cwd => "/usr/share/doc/${version_php_docs}/en/html/",
        command => "/usr/bin/php_completions.sh",
        refreshonly => true,
        require => File['/usr/bin/php_completions.sh'];
      }

      package { xdebug:
        category => 'dev-php5',
        ensure   => 'installed',
        require  =>  Package['php'],
        tag      => 'buildhost'
      }

      gentoo_keywords { 'PEAR-PHP_CodeSniffer':
        context  => 'tool_php_pear_codesniffer',
        package  => '=dev-php/PEAR-PHP_CodeSniffer-1.2.0',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'PEAR-PHP_CodeSniffer':
        category => 'dev-php',
        ensure   => 'installed',
        require  =>  [Package['php'],
                      Gentoo_keywords['PEAR-PHP_CodeSniffer']],
        tag      => 'buildhost'
      }
      package { phpunit:
        category => 'dev-php5',
        ensure   => 'installed',
        require  =>  Package['php'],
        tag      => 'buildhost'
      }
      package { PEAR-PhpDocumentor:
        category => 'dev-php',
        ensure   => 'installed',
        require  =>  Package['php'],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { php5: ensure   => 'installed' }
      package { php5-cli: ensure   => 'installed' }
      package { php5-curl: ensure   => 'installed' }
      package { php5-gd: ensure   => 'installed' }
      package { php-gettext: ensure   => 'installed' }
      package { php5-imap: ensure   => 'installed' }
      package { php5-ldap: ensure   => 'installed' }
      package { php5-sqlite: ensure   => 'installed' }
      package { php5-xdebug: ensure   => 'installed' }
      package { phpunit: ensure   => 'installed' }
      package { php-codesniffer: ensure   => 'installed' }
    }
  }
}
