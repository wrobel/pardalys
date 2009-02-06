# Class kolab::service::kolab
#
#  Provides the core configuration for the Kolab Server.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package kolab_service_kolab
#
class kolab::service::kolab {

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
        content => template('kolab_service_kolab/kolab.conf'),
        replace => 'no',
        require => File["$kolab_confdir"];
        "$kolab_globalsfile":
        content => template('kolab_service_kolab/kolab.globals'),
        require => File["$kolab_confdir"];
      }

      if $kolab_bootstrap {
        sslcert{ 
          "$kolab_pki_dir":
            hostname => "$kolab_fqdnhostname",
            group    => "$kolab_grp",
            ensure   => 'present',
            require => Group["$kolab_grp"];
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
