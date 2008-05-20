# Class service::kolab
#
#  Provides basic Kolab server elements
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_kolab
#
# @fact operatingsystem Allows to choose the correct package name
#                       depending on the operating system
# @fact sbindir         Directory with super user applications
# @fact bindir          Directory with user applications
# @fact keyword         The keyword for the system which is used to
#                       select unstable packages
#
class service::kolab {

  $fqdnhostname    = get_var('kolab_fqdnhostname',    get_var('kolab_bootstrap_fqdnhostname', $hostname))
  $is_master       = get_var('kolab_is_master',       get_var('kolab_bootstrap_is_master',    'true'))
  $domain          = get_var('kolab_domain',          get_var('kolab_bootstrap_domain',       $fqdnhostname))
  $base_dn         = get_var('kolab_base_dn',         get_var('kolab_bootstrap_base_dn',      dnfromdomain($domain)))
  $bind_pw         = get_var('kolab_bind_pw',         get_var('kolab_bootstrap_bind_pw',      generate("$bindir/openssl", 'rand', '-base64',  '12')))
  $bind_pw_sq      = shellquote($bind_pw)
  $bind_pw_hash    = generate("$sbindir/slappasswd",'-s',"$bind_pw_sq")
  $ldap_uri        = get_var('kolab_ldap_uri',        'ldap://127.0.0.1:389')
  # We do not support slave setup at the moment
  $ldap_master_uri = get_var('kolab_ldap_master_uri', 'ldap://127.0.0.1:389')
  $php_pw          = get_var('kolab_php_pw',          generate("$bindir/openssl", 'rand', '-base64', '30'))
  $calendar_pw     = get_var('kolab_calendar_pw',     generate("$bindir/openssl", 'rand', '-base64', '30'))

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
