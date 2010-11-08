$facts = {}

$facts['sysconfdir'] = '/etc'
$facts['sbindir']    = '/usr/sbin'
$facts['bindir']     = '/usr/bin'
$facts['localstatedir']   = '/var'
$facts['libexecdir'] = '/usr/lib'

$facts['sysrundir']     = $facts['localstatedir'] + '/run'
$facts['libdir']     = $facts['localstatedir'] + '/lib'
$facts['logdir']     = $facts['localstatedir'] + '/log'
$facts['scriptsdir']     = $facts['bindir']

$facts['usr']        = 'root'
$facts['grp']        = 'kolab'
$facts['rusr']       = 'root'
$facts['rgrp']       = 'root'
$facts['musr']       = 'root'
$facts['mgrp']       = 'root'

$facts['pki_grp']    = $facts['grp']
$facts['pki_dir']    = $facts['sysconfdir'] + '/ssl/system'

$facts['ldapserver_usr']       = 'root'
$facts['ldapserver_grp']       = 'ldap'
$facts['ldapserver_rusr']       = 'ldap'
$facts['ldapserver_rgrp']       = 'ldap'
$facts['ldapserver_confdir']       = $facts['sysconfdir'] + '/openldap'
$facts['ldapserver_dir']       = $facts['libdir'] + '/openldap-data'
$facts['ldap_service']       = 'slapd'
$facts['ldapserver_schemadir']       = $facts['ldapserver_confdir'] + '/schema'
$facts['ldapserver_pidfile']       = $facts['sysrundir'] + '/openldap/slapd.pid'
$facts['ldapserver_argsfile']       = $facts['sysrundir'] + '/openldap/slapd.args'
$facts['ldapserver_logfile']       = 'UNSET'
$facts['ldapserverslurpd_pidfile']    = 'UNSET'
$facts['ldapserver_replogfile']       = 'UNSET'

$facts['sasl_smtpconffile'] = $facts['sysconfdir'] + '/sasl2/smtpd.conf'
$facts['sasl_authdconffile'] = $facts['sysconfdir'] + '/sasl2/saslauthd.conf'
# FIXME: Not used as logging to syslog (on kolab used by kolabd/kolabd/namespace/libexec/showlog.in)
$facts['sasl_logfile'] = 'UNSET'

$facts['emailserver_confdir']  = $facts['sysconfdir'] + '/postfix'

$facts['imap_confdir'] = $facts['sysconfdir']
$facts['imap_confperm'] = '640'
$facts['imap_usr'] = 'cyrus'
$facts['imap_grp'] = 'mail'

$facts['imap_statedir'] = $facts['localstatedir'] + '/imap'
$facts['imap_spool'] = $facts['localstatedir'] + '/spool/imap'
$facts['imap_sievedir'] = $facts['imap_statedir'] + '/sieve'

$facts['imap_lmtp'] = $facts['imap_statedir'] + '/socket/lmtp'
$facts['imap_notify_socket'] = $facts['imap_statedir'] + '/socket/notify'

$facts['imap_masterlogfile'] = 'UNSET'
$facts['imap_misclogfile'] = 'UNSET'
$facts['imap_pkg'] = 'cyrus-imapd'


$facts['confdir']     = $facts['sysconfdir'] + '/kolab'
$facts['globalsfile'] = $facts['confdir'] + '/kolab.globals'

$facts['confscript'] = $facts['sbindir'] + '/pardalys'
$facts['kolabrc'] = 'UNSET'

$facts['kolabd_pidfile'] = $facts['sysrundir'] + '/kolabd/kolabd.pid'
$facts['kolabd_statedir'] = $facts['libdir'] + '/kolabd/'
$facts['graveyard_uidcache'] = $facts['kolabd_statedir'] + '/graveyard-uidcache.db'
$facts['graveyard_tscache'] = $facts['kolabd_statedir'] + '/graveyard-tscache.db'
$facts['mailboxuiddb'] = $facts['kolabd_statedir'] + '/mailbox-uidcache.db'

$facts['wui'] = 'UNSET'

$facts['templatedir'] = 'UNSET'

$facts['backupfiles'] = 'UNSET'
$facts['backupdir'] = 'UNSET'

$facts['with_openpkg'] = 'no'

$facts['tar_bin'] = '/bin/tar'
