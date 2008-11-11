import 'os_gentoo'

# Class tool::perl::kolab
#
#  Provides the kolabd daemon and other Kolab Server scripts.
#
# Parameters 
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_kolabd
#
# @module root           The root module is required to determine the installed
#                        amavis version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
# @module kolab_service_kolab  Provides the kolab configuration.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
#
class tool::perl::kolab {

  # Package installation
  case $operatingsystem {
    gentoo: {
      gentoo_unmask { 'perl-kolab':
        context  => 'kolab_service_kolabd_perl_kolab',
        package  => 'dev-perl/perl-kolab',
        tag      => 'buildhost'
      }
      gentoo_keywords { 'perl-kolab':
        context  => 'kolab_service_kolabd_perl_kolab',
        package  => 'dev-perl/perl-kolab',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'perl-kolab':
        category => 'dev-perl',
        ensure   => 'installed',
        require  => Gentoo_keywords['perl-kolab'],
        tag      => 'buildhost'
      }
    }
    default: {
      package { 'perl-kolab':
        ensure   => 'installed';
      }
    }
  }
}
