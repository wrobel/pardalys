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
  @file { 
    '/etc/apt/sources.list.d/multiverse.list':
    source  => 'puppet:///modules/os_ubuntu/repository_multiverse';
  }
}
