import 'os'
import 'os_gentoo'

# Class tool::system
#
#  Provides some common system tools
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_system
#
class tool::system {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_use_flags { db:
        context => 'tools_system_common_db',
        package => 'sys-libs/db',
        use     => 'doc',
        tag     => 'buildhost'
      }
      package { db:
        category => 'sys-libs',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['db']
      }

      gentoo_use_flags { perl:
        context => 'tools_system_common_perl',
        package => 'dev-lang/perl',
        use     => 'berkdb gdbm',
        tag     => 'buildhost'
      }
      package { perl:
        category => 'dev-lang',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['perl']
      }

      gentoo_license { sun-jdk:
        context => 'tools_system_sun_jdk',
        package => 'dev-java/sun-jdk',
        license     => 'dlj-1.1',
        tag     => 'buildhost'
      }
      package { sun-jdk:
        category => 'dev-java',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_license['sun-jdk']
      }

      gentoo_use_flags { lcdf-typetools:
        context => 'tools_system_common_lcdf_typetools',
        package => 'app-text/lcdf-typetools',
        use     => 'kpathsea',
        tag     => 'buildhost'
      }
      package { lcdf-typetools:
        category => 'app-text',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['lcdf-typetools']
      }

      package { texlive:
        category => 'app-text',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Package['lcdf-typetools']
      }

      package { cvs:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { mercurial:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      # FIXME: Remove the "apache2" USE flag once we serve no
      # subversion anymore
      gentoo_use_flags { subversion:
        context => 'tool_subversion_subversion',
        package => 'dev-vcs/subversion',
        use     => 'emacs bash-completion apache2 -dso',
        tag     => 'buildhost'
      }
      package { subversion:
        category => 'dev-vcs',
        ensure   => 'installed',
        require  =>  Gentoo_use_flags['subversion'],
        tag      => 'buildhost'
      }

      gentoo_use_flags { libpcre:
        context => 'tools_system_common_libpcre',
        package => 'dev-libs/libpcre',
        use     => 'cxx zlib bzip2 unicode',
        tag     => 'buildhost'
      }
      package { libpcre:
        category => 'dev-libs',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['libpcre']
      }

      gentoo_use_flags { ncurses:
        context => 'tools_system_common_ncurses',
        package => 'sys-libs/ncurses',
        use     => 'doc unicode',
        tag     => 'buildhost'
      }
      package { ncurses:
        category => 'sys-libs',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['ncurses']
      }

      # for the hostx tool
      package { host:
        category => 'net-dns',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { unzip:
        category => 'app-arch',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_use_flags['libpcre']
      }

      package { slocate:
        category => 'sys-apps',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { lsof:
        category => 'sys-process',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { sqlite:
        category => 'dev-db',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { strace:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { ltrace:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { patchutils:
        category => 'dev-util',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { screen:
        category => 'app-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { dhcpcd:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { netkit-telnetd:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      gentoo_keywords { scripts-gw:
        context  => 'tool_system_scripts-gw',
        package  => '=app-misc/scripts-gw-1.3.2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { scripts-gw:
        category => 'app-misc',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['scripts-gw']
      }

      gentoo_keywords { overlay-utils:
        context  => 'tool_system_overlay-utils',
        package  => 'app-portage/overlay-utils',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { overlay-utils:
        category => 'app-portage',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['overlay-utils']
      }

      gentoo_keywords { cadaver:
        context  => 'tool_system_cadaver',
        package  => '=net-misc/cadaver-0.23.2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { cadaver:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['cadaver']
      }

      gentoo_keywords { webpy:
        context  => 'tool_system_webpy',
        package  => '=dev-python/webpy-0.23',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { webpy:
        category => 'dev-python',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_keywords['webpy']
      }

      gentoo_keywords { libgeier:
        context  => 'tool_system_libgeier',
        package  => '=dev-libs/libgeier-0.9',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_keywords { xmlsec:
        context  => 'tool_system_xmlsec',
        package  => '=dev-libs/xmlsec-1.2.11',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_keywords { ledger:
        context  => 'tool_system_ledger',
        package  => '=app-office/ledger-2.6.1',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { ledger:
        category => 'app-office',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => [Gentoo_keywords['libgeier'],
                     Gentoo_keywords['xmlsec'],
                     Gentoo_keywords['ledger']];
      }

      package { iproute2:
        category => 'sys-apps',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { sudo:
        category => 'app-admin',
        ensure   => 'installed',
        tag      => 'buildhost'
      }
      package { keychain:
        category => 'net-misc',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      package { ldapvi:
        category => 'net-nds',
        ensure   => 'installed',
        tag      => 'buildhost'
      }

      # Ensure the system knows how to handle the rxvt-unicode terminal
      file {
        '/usr/share/terminfo/r/rxvt-unicode':
        source => 'puppet:///modules/tool_system/rxvt-unicode',
        require => Package['ncurses'];
      }

    }
    default:
    {
      package { bison: ensure => 'installed' }
      package { flex: ensure => 'installed' }
      package { gcc: ensure => 'installed' }
      package { automake: ensure => 'installed' }
      package { libtool: ensure => 'installed' }
      package { autoconf: ensure => 'installed' }
      package { tcl: ensure => 'installed' }
      package { perl: ensure => 'installed' }
      package { default-jdk: ensure => 'installed' }
      package { ant: ensure => 'installed' }
      package { lcdf-typetools: ensure => 'installed' }
      package { texlive: ensure => 'installed' }
      package { texlive-lang-german: ensure => 'installed' }
      package { texlive-latex-extra: ensure => 'installed' }
      package { cvs: ensure => 'installed' }
      package { mercurial: ensure => 'installed' }
      package { subversion: ensure => 'installed' }
      package { bind9-host: ensure => 'installed' } # for the hostx tool
      package { unzip: ensure => 'installed' }
      package { mlocate: ensure => 'installed' }
      package { lsof: ensure => 'installed' }
      package { sqlite: ensure => 'installed' }
      package { strace: ensure => 'installed' }
      package { ltrace: ensure => 'installed' }
      package { patchutils: ensure => 'installed' }
      package { screen: ensure => 'installed' }
      package { dhcpcd: ensure => 'installed' }
      package { telnet: ensure => 'installed' }
      package { scripts-gw: ensure => 'installed' } # Still required?
      package { cadaver: ensure => 'installed' }
      package { python-webpy: ensure => 'installed' }
      package { ledger: ensure => 'installed' }
      package { iproute: ensure => 'installed' }
      package { sudo: ensure => 'installed' }
      package { keychain: ensure => 'installed' }
      package { ldapvi: ensure => 'installed' }
      package { language-support-de: ensure => 'installed' }
      package { language-support-en: ensure => 'installed' }
      package { language-support-fr: ensure => 'installed' }
      package { language-support-sv: ensure => 'installed' }
      package { aspell: ensure => 'installed' }
      package { aspell-en: ensure => 'installed' }
      package { aspell-de: ensure => 'installed' }
      package { aspell-fr: ensure => 'installed' }
      package { aspell-sv: ensure => 'installed' }
      package { newsbeuter: ensure => 'installed' }
      package { topgit: ensure => 'installed' }
      package { html2ps: ensure => 'installed' }
    }
  }

  file {
    '/etc/cron.daily/check_security':
    source => 'puppet:///modules/tool_system/check_security',
    owner => 'root',
    group => 'root',
    mode    => 755;
    '/root/.log':
    ensure => 'directory';
  }

}
