# Class gentoo::settings
#
#  Provide basic system values for the Gentoo distributions
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os_gentoo
#
class gentoo::settings
{
  $sysconfdir = '/etc'
}

# Class gentoo::etc::portage 
#
#  Ensure that all /etc/portage/package.* locations are actually
#  handled as directories. This allows to easily manage the package
#  specific settings for Gentoo.
#  
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package os_gentoo
#
class gentoo::etc::portage
{
  # Check that we are able to handle /etc/portage/package.* as 
  # directories

  file { 'package.use::directory':
    path   => '/etc/portage/package.use',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.keywords::directory':
    path   => '/etc/portage/package.keywords',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.mask::directory':
    path   => '/etc/portage/package.mask',
    ensure => 'directory',
    tag    => 'buildhost'
  }

  file { 'package.unmask::directory':
    path   => '/etc/portage/package.unmask',
    ensure => 'directory',
    tag    => 'buildhost'
  }
}

# Function gentoo_use_flags
#
#  Specify use flags for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param use      The use flags to apply
#
define gentoo_use_flags ($context = '',
                         $package = '', 
                         $use = '')
{

  file { "/etc/portage/package.use/${context}":
    content => "$package $use",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => File['package.use::directory'],
    tag     => 'buildhost'
  }

}

# Function gentoo_keywords
#
#  Specify keywords for a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#  @param keywords The keywords to apply
#
define gentoo_keywords ($context  = '',
                        $package  = '', 
                        $keywords = '')
{

  file { "/etc/portage/package.keywords/${context}":
    content => "$package $keywords",
    owner => 'root',
    group => 'root',
    mode => 644,
    require => File['package.keywords::directory'],
    tag    => 'buildhost'
  }

}

# Function gentoo_unmask
#
#  Unmask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define gentoo_unmask ($context  = '',
                      $package  = '')
{

  file { "/etc/portage/package.unmask/${context}":
    content => "$package",
    owner => 'root',
    group => 'root',
    mode => 644,
    require => File['package.unmask::directory'],
    tag    => 'buildhost'
  }

}

# Function gentoo_mask
#
#  Mask a package.
#
#  @param context  A unique context for the package
#  @param package  The package atom
#
define gentoo_mask ($context  = '',
                    $package  = '')
{

  file { "/etc/portage/package.mask/${context}":
    content => "$package",
    owner => 'root',
    group => 'root',
    mode => 644,
    require => File['package.mask::directory'],
    tag    => 'buildhost'
  }

}

