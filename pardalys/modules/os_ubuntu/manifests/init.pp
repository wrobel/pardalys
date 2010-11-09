# Class ubuntu::repositories::multiverse
#
#  Provides the multiverse repository.
#  
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os_ubuntu
#
class ubuntu::repositories::multiverse
{
  @file { 'multiverse_list':
    path => '/etc/apt/sources.list.d/multiverse.list',
    owner => 'root',
    group => 'root',
    source  => 'puppet:///modules/os_ubuntu/repository_multiverse';
  }
}

# Class ubuntu::repositories::pardus
#
#  Provides the pardus repository.
#  
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os_ubuntu
#
class ubuntu::repositories::pardus
{
  @file { 'pardus_list':
    path => '/etc/apt/sources.list.d/pardus.list',
    owner => 'root',
    group => 'root',
    source  => 'puppet:///modules/os_ubuntu/repository_pardus';
  }
}
