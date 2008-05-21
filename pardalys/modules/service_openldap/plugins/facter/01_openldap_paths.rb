# Set basic system paths

if Facter.operatingsystem == 'Gentoo'
  Facter.add('openldap_confdir')   do setcode do Facter.sysconfdir + '/openldap'       end
  Facter.add('openldap_schemadir') do setcode do Facter.openldap_confdir + '/schema'   end
  Facter.add('openldap_datadir')   do setcode do Facter.statelibdir + '/openldap-data' end
  Facter.add('openldap_pidfile')   do setcode do Facter.sysrundir + '/slapd.pid' end
  Facter.add('openldap_argsfile')  do setcode do Facter.sysrundir + '/slapd.args' end
  Facter.add('openldap_usr')       do setcode do 'root' end
  Facter.add('openldap_rusr')      do setcode do 'ldap' end
  Facter.add('openldap_grp')       do setcode do 'ldap' end
else
  Facter.add('openldap_confdir')   do setcode do Facter.sysconfdir + '/openldap'       end
  Facter.add('openldap_schemadir') do setcode do Facter.openldap_confdir + '/schema'   end
  Facter.add('openldap_datadir')   do setcode do Facter.statelibdir + '/openldap-data' end
  Facter.add('openldap_pidfile')   do setcode do Facter.sysrundir + '/slapd.pid' end
  Facter.add('openldap_argsfile')  do setcode do Facter.sysrundir + '/slapd.args' end
  Facter.add('openldap_usr')       do setcode do 'root' end
  Facter.add('openldap_rusr')      do setcode do 'ldap' end
  Facter.add('openldap_grp')       do setcode do 'ldap' end
end
