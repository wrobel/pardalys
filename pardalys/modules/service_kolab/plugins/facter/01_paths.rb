# Set basic system paths

if Facter.operatingsystem == 'Gentoo'
  Facter.add('kolab_confdir')       do setcode do Facter.sysconfdir + '/kolab'              end
  Facter.add('kolab_configfile')    do setcode do Facter.kolab_confdir + '/kolab.conf'      end
  Facter.add('kolab_globalsfile')   do setcode do Facter.kolab_confdir + '/kolab.globals'   end
  Facter.add('kolab_bootstrapfile') do setcode do Facter.kolab_confdir + '/kolab.bootstrap' end
else
  Facter.add('kolab_confdir')       do setcode do Facter.sysconfdir + '/kolab'              end
  Facter.add('kolab_configfile')    do setcode do Facter.kolab_confdir + '/kolab.conf'      end
  Facter.add('kolab_globalsfile')   do setcode do Facter.kolab_confdir + '/kolab.globals'   end
  Facter.add('kolab_bootstrapfile') do setcode do Facter.kolab_confdir + '/kolab.bootstrap' end
end
