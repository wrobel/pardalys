# Class service::kolab
#
#  Provides basic Kolab server elements
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_kolab
#
# @fact sbindir                Path to administrator programs
# @fact sysconfdir             System configuration directory
# @fact kolab_confscript       The script handling the kolab configuration
# @fact kolab_usr              The kolab user
# @fact kolab_grp              The kolab group
# @fact kolab_rusr             The restricted kolab user
# @fact kolab_rgrp             The restricted kolab group
# @fact kolab_musr             The unpriviledged kolab user
# @fact kolab_mgrp             The unpriviledged kolab group
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
class service::kolab {

  file { 
    "$kolab_confdir":
    ensure  => 'directory';
    "$kolab_configfile":
    content => template('service_kolab/kolab.conf'),
    require => File["$kolab_confdir"];
    "$kolab_globalsfile":
    content => template('service_kolab/kolab.globals'),
    require => File["$kolab_confdir"];
  }
}
