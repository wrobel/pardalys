# Set basic system paths

if Facter.operatingsystem == 'Gentoo'
  Facter.add('openldap_confdir')   do setcode do Facter.sysconfdir + '/openldap'       end end
  Facter.add('openldap_schemadir') do setcode do Facter.openldap_confdir + '/schema'   end end
  Facter.add('openldap_datadir')   do setcode do Facter.statelibdir + '/openldap-data' end end
  Facter.add('openldap_pidfile')   do setcode do Facter.sysrundir + '/slapd.pid' end end
  Facter.add('openldap_argsfile')  do setcode do Facter.sysrundir + '/slapd.args' end end
  Facter.add('openldap_usr')       do setcode do 'root' end end
  Facter.add('openldap_rusr')      do setcode do 'ldap' end end
  Facter.add('openldap_grp')       do setcode do 'ldap' end end
else
  Facter.add('openldap_confdir')   do setcode do Facter.sysconfdir + '/openldap'       end end
  Facter.add('openldap_schemadir') do setcode do Facter.openldap_confdir + '/schema'   end end
  Facter.add('openldap_datadir')   do setcode do Facter.statelibdir + '/openldap-data' end end
  Facter.add('openldap_pidfile')   do setcode do Facter.sysrundir + '/slapd.pid' end end
  Facter.add('openldap_argsfile')  do setcode do Facter.sysrundir + '/slapd.args' end end
  Facter.add('openldap_usr')       do setcode do 'root' end end
  Facter.add('openldap_rusr')      do setcode do 'ldap' end end
  Facter.add('openldap_grp')       do setcode do 'ldap' end end
end
