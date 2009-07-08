import 'os_gentoo'

# Class service::postfix
#
#  Provides a configuration for the postfix MTA
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package service_postfix
#
# @module root           The root module is required to determine the installed
#                        postfix version.
# @module os             The os module is required to determine basic system
#                        paths.
# @module os_gentoo      The os_gentoo module is required for Gentoo specific
#                        package installation.
# @module kolab_service_kolab  Provides the kolab configuration directory.
# @module service_sasl   Provides the required saslauthd service.
#
# @fact operatingsystem  Allows to choose the correct package name
#                        depending on the operating system. In addition
#                        required to set additional tasks depending on
#                        the distribution.
# @fact version_postfix  The postfix version currently installed
#
# @fact kolab_fqdnhostname          Our primary Kolab hostname
# @fact kolab_ldap_uri              URI for our LDAP server
# @fact kolab_base_dn               The base DN of the LDAP server
# @fact kolab_bind_dn_restricted    The DN for the user with restricted access
# @fact kolab_bind_pw_restricted    The password for the user with restricted access
# @fact kolab_bind_addr             The interface postfix should bind to
# @fact kolab_bind_any              Should we bind to any interface?
# @fact kolab_local_addr            Our local IP (usually 127.0.0.1)
# @fact kolab_postfix_mydomain      Our primary mail domain
# @fact kolab_postfix_mynetworks    Networks that may relay through us
# @fact kolab_postfix_mydestination Our mail domains
# @fact kolab_postfix_relayhost     We relay through this host
# @fact kolab_postfix_relayport     Port of the relay host
# @fact kolab_kolabhost             The hosts of our Kolab network
# @fact kolab_postfix_enable_virus_scan Enable the amavis scan
# @fact kolab_postfix_allow_unauthenticated Allow unauthenticated
#                                           receiving of mails
# @fact kolab_cyrus_admin           Manager account for LMTP delivery
# @fact kolab_bind_pw               Manager password
# @fact kolabconfdir                Kolab configuration directory
#
# @fact postfix_enable_amavis_fallback  Exclude amavis if it is down
# @fact postfix_log_kolabpolicy         If you need verbose information from
#                                       the kolab policy script
# @fact postfix_remote_spambox_ip       IP of a remote spam filter
# @fact postfix_remote_spambox_port     Port of the remote spam filter
#
# @fact kolab_kolabfilter_verify_from_header         Should the kolab filter verify the "From" headers
# @fact kolab_kolabfilter_allow_sender_header        Should the kolab filter use "Sender" headers
# @fact kolab_kolabfilter_reject_forged_from_header  Should the kolab filter reject forged from headers
# @fact kolab_calendar_id       The calendar id for storing calendar events
# @fact kolab_calendar_pw       The password for the calendar user
#
class service::postfix {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      # The main postfix package
      gentoo_use_flags { 'postfix':
        context => 'service_postfix_postfix',
        package => 'mail-mta/postfix',
        use     => 'ldap sasl ssl mailwrapper',
        tag     => 'buildhost'
      }
      package { 'postfix':
        category => 'mail-mta',
        ensure   => 'installed',
        require  => Gentoo_use_flags['postfix'],
        tag      => 'buildhost';
      }
      # We need the Horde::Kolab modules
      gentoo_use_flags { 'c-client-postfix':
        context => 'service_postfix_cclient',
        package => 'net-libs/c-client',
        use     => 'kolab',
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Argv_postfix':
        context => 'service_postfix_Horde_Argv',
        package => '=dev-php/Horde_Argv-0.1.0',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      gentoo_keywords { 'Horde_Kolab_Filter':
        context => 'service_postfix_Horde_Kolab_Filter',
        package => 'dev-php/Horde_Kolab_Filter',
        keywords => "~$keyword",
        require  =>  Package['Horde_Kolab_Storage'],
        tag      => 'buildhost'
      }
      package { 'Horde_Kolab_Filter':
        category => 'dev-php',
        ensure   => 'installed',
        require  =>  [ Gentoo_use_flags['c-client-postfix'],
                       Gentoo_keywords['Horde_Kolab_Filter'],
                       Gentoo_keywords['Horde_Argv_postfix']],
        tag      => 'buildhost'
      }
    }
    default:
    {
      package { 'postfix':
        ensure  => 'installed';
      }
    }
  }

  $sysconfdir         = $os::sysconfdir

  $postfix_confdir    = "${os::sysconfdir}/postfix"
  $postfix_aliasdir   = "${os::sysconfdir}/mail"
  $postfix_aliases    = "${postfix_aliasdir}/aliases"

  $postfix_sysadmin = get_var('kolab_admin_mail', 'root@localhost')

  $postfix_script_user = 'nobody'

  $template_postfix = template_version($version_postfix, '2.4.6-r2@:2.4.6-r2,', '2.4.6-r2')

  $kolab_hostname = get_var('kolab_fqdnhostname')

  $ldap_uri = get_var('kolab_ldap_uri', 'ldap://127.0.0.1:389')
  $base_dn = get_var('kolab_base_dn')
  $bind_dn_nobody = get_var('kolab_bind_dn_restricted')
  $bind_pw_nobody = get_var('kolab_bind_pw_restricted')

  $lmtp_user = get_var('kolab_cyrus_admin', 'manager')
  $lmtp_pass = get_var('kolab_bind_pw')

  $bind_addr = get_var('kolab_bind_addr', '0.0.0.0')
  $local_addr = get_var('kolab_local_addr', '127.0.0.1')
  $bind_any = get_var('kolab_bind_any', true)
  if $bind_any {
    $cyrus_connect = $local_addr
  } else {
    $cyrus_connect = $bind_addr
  }

  $mydomain = get_var('kolab_postfix_mydomain')
  $mynetworks = split(get_var('kolab_postfix_mynetworks'), ',')
  $mydestination = split(get_var('kolab_postfix_mydestination'), ',')

  $relayhost = get_var('kolab_postfix_relayhost', false)
  $relayport = get_var('kolab_postfix_relayport', 25)

  $permithosts = split(get_var('kolab_kolabhost'), ',')

  $allow_unauthenticated = get_var('kolab_postfix_allow_unauthenticated', true)
  $enable_virus_scan = get_var('kolab_postfix_enable_virus_scan', true)
  $enable_amavis_fallback = get_var('postfix_enable_amavis_fallback', false)
  $log_kolabpolicy = get_var('postfix_log_kolabpolicy', false)

  $kolabfilterconfig = "$kolab_confdir/kolabfilter.conf"
  $verify_from_header = get_var('kolab_kolabfilter_verify_from_header', false)
  $allow_sender_header = get_var('kolab_kolabfilter_allow_sender_header', false)
  $reject_forged_from_header = get_var('kolab_kolabfilter_reject_forged_from_header', false)
  $calendar_id = get_var('kolab_calendar_id', false)
  $calendar_pw = get_var('kolab_calendar_pw', false)

  $remote_spambox_ip   = get_var('postfix_remote_spambox_ip', false)
  $remote_spambox_port = get_var('postfix_remote_spambox_port', '10024')

  file { 
    "${postfix_confdir}/master.cf":
    content => template("service_postfix/master.cf_${template_postfix}"),
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    "${postfix_confdir}/main.cf":
    content => template("service_postfix/main.cf_${template_postfix}"),
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    "${postfix_aliases}":
    content => template("service_postfix/aliases"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_aliases']];
    "${postfix_confdir}/canonical":
    source  => 'puppet:///service_postfix/canonical',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_canonical']];
    "${postfix_confdir}/kolabvirtual":
    source  => 'puppet:///service_postfix/kolabvirtual',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_canonical']];
    "${postfix_confdir}/ldapdistlist":
    content => template("service_postfix/ldapdistlist"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldapdistlist']];
    "${postfix_confdir}/ldaptransport":
    content => template("service_postfix/ldaptransport"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldaptransport']];
    "${postfix_confdir}/ldapvirtual":
    content => template("service_postfix/ldapvirtual"),
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_ldapvirtual']];
    "${postfix_confdir}/relocated":
    source  => 'puppet:///service_postfix/relocated',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_relocated']];
    "${postfix_confdir}/transport":
    source  => 'puppet:///service_postfix/transport',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_relocated']];
    "${postfix_confdir}/virtual":
    source  => 'puppet:///service_postfix/virtual',
    mode    => 640,
    require => Package['postfix'],
    notify  => [Service['postfix'], Exec['map_virtual']];
    "${postfix_confdir}/header_checks":
    source  => 'puppet:///service_postfix/header_checks',
    mode    => 640,
    require => Package['postfix'],
    notify  => Service['postfix'];
    "${kolab_confdir}/kolab_smtpdpolicy.conf":
    content => template("service_postfix/kolab_smtpdpolicy.conf"),
    require => Package['postfix'];
    "${kolabfilterconfig}":
    content => template("service_postfix/kolabfilter.conf"),
    require => Package['Horde_Kolab_Filter'];
  }

  if defined(File['/etc/monit.d']) {
    file {
      '/etc/monit.d/postfix':
      source  => 'puppet:///service_cron/monit_postfix';
    }
  }

  exec {
    'map_aliases':
    cwd  => "${postfix_aliasdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postalias aliases',
    require => Package['postfix'],
    subscribe   => File["${postfix_aliases}"],
    refreshonly => true;
    'map_canonical':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap canonical',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/canonical"],
    refreshonly => true;
    'map_kolabvirtual':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap kolabvirtual',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/kolabvirtual"],
    refreshonly => true;
    'map_ldapdistlist':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldapdistlist',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/ldapdistlist"],
    refreshonly => true;
    'map_ldaptransport':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldaptransport',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/ldaptransport"],
    refreshonly => true;
    'map_ldapvirtual':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap ldapvirtual',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/ldapvirtual"],
    refreshonly => true;
    'map_relocated':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap relocated',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/relocated"],
    refreshonly => true;
    'map_transport':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap transport',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/transport"],
    refreshonly => true;
    'map_virtual':
    cwd  => "${postfix_confdir}",
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'postmap virtual',
    require => Package['postfix'],
    subscribe   => File["${postfix_confdir}/virtual"],
    refreshonly => true;
  }

  service { 'postfix':
    ensure    => 'running',
    enable    => true,
    require => [ Package['postfix'], Service['saslauthd']];
  }

  case $operatingsystem {
    gentoo: {
      # SASL configuration for the smtpd process
      file { 
        "${service::sasl::sasl_confdir}/smtpd.conf":
        source => 'puppet:///service_postfix/smtpd.conf',
        require => Package['postfix'];
      }

      # Ensure that the service starts with the system
      file { '/etc/runlevels/default/postfix':
        ensure => '/etc/init.d/postfix',
        require  => Package['postfix']
      }
    }
  }
}
