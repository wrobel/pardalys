# Class service::kolab
#
#  Provides basic Kolab server elements
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_kolab
#
# @param os::sbindir           Path to administrator programs
# @param os::sysconfdir        System configuration directory
#
# @fact kolab_confdir          Path to the kolab configuration directory
# @fact kolab_configfile       Path to the kolab app configuration file
# @fact kolab_globalsfile      Path to the kolab global configuration file
#
# @fact kolab_fqdnhostname     The fully qualified hostname
# @fact kolab_is_master        Is this a master kolab server?
# @fact kolab_postfix_mydomain The mail domain served by this server
# @fact kolab_base_dn          Base LDAP DN for the server
# @fact kolab_bind_dn          Manager DN for the server
# @fact kolab_bind_pw          Manager pass for the server
# @fact kolab_bind_pw_hash     Hash of the manager pass
# @fact kolab_ldap_uri         Location of the LDAP server
# @fact kolab_ldap_master_uri  Location of the LDAP master server
# @fact kolab_php_dn           Unpriviled user DN
# @fact kolab_php_pw           Unpriviled user password
# @fact kolab_calendar_id      Calendar user id
# @fact kolab_calendar_pw      Calendar user password
#
# @fact kolab_bootstrapfile    Path to the kolab bootstrap configuration
#
class service::kolab {

  if $kolab_ldap_error {
    case $kolab_slapd_recovery {
      # We were unable to connect to the LDAP server and we are
      # lacking some central configuration values now. So we should
      # NOT start to rewrite any configuration files. As long as the
      # user did not ask for slapd recovery we should simply error out
      # here
      default: {

        fail("
        Error: $kolab_ldap_error

        Could not connect to the LDAP server! This is fatal. 

        If you did not bootstrap the server yet you need to create
        $kolab_bootstrapfile and run p@rdalys to initialize the
        server.

        Maybe you already bootstrapped the server, your LDAP server
        failed and you are unable to restart it. Then you can try to
        add the line \"slapd_recovery:true\" to $kolab_globalsfile and
        rerun p@rdalys to try to repair the LDAP configuration.

        " )

      }
      # The user wants us to try to reconstruct the slapd
      # configuration. In that case we try to keep our actions to an
      # absolute minimum that hopefully leads to reactivation of the
      # slapd server.
      "true": {
        crit('Could not connect to LDAP server! You asked for recovery.')
      }
    }
  }

  $kolab_confscript = "${os::sbindir}/pardalys"
  $kolab_usr        = 'root'
  $kolab_grp        = 'kolab'
  $kolab_rusr       = 'root'
  $kolab_rgrp       = 'root'
  $kolab_musr       = 'root'
  $kolab_mgrp       = 'root'
  $sysconfdir       = $os::sysconfdir
  $sbindir          = $os::sbindir

  group {
    "$kolab_grp":
      ensure => "present",
      provider => "groupadd"
  }

  case $kolab_slapd_recovery {
    default: {
      file { 
        "$kolab_confdir":
        ensure  => 'directory';
        "$kolab_configfile":
        content => template('service_kolab/kolab.conf'),
        require => File["$kolab_confdir"];
        "$kolab_globalsfile":
        content => template('service_kolab/kolab.globals'),
        replace => 'no',
        require => File["$kolab_confdir"];
      }

      if $kolab_bootstrap {
        sslcert{ 
          "$kolab_confdir":
          require  => "${tool::openssl::ssl_confdir}/system",
          hostname => "$kolab_fqdnhostname",
          group    => "$kolab_grp",
          ensure   => 'present';
        }

        file {
          "$kolab_bootstrapfile":
          ensure => 'absent';
        }
      }
    }
    "true": {
      crit('LDAP recovery - Main Kolab configuration files remain untouched.')
    }
  }
}
