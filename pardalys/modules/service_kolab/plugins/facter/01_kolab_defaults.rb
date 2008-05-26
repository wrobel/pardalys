# Set basic system paths

Facter.add('kolab_confdir')       do setcode do Facter.sysconfdir + '/kolab'              end end
Facter.add('kolab_ssldir')        do setcode do Facter.kolab_confdir                      end end
Facter.add('kolab_configfile')    do setcode do Facter.kolab_confdir + '/kolab.conf'      end end
Facter.add('kolab_globalsfile')   do setcode do Facter.kolab_confdir + '/kolab.globals'   end end
Facter.add('kolab_bootstrapfile') do setcode do Facter.kolab_confdir + '/kolab.bootstrap' end end
Facter.add('kolab_confscript')    do setcode do Facter.sbindir + '/kolabconf'             end end
Facter.add('kolab_usr')           do setcode do 'root'                                    end end
Facter.add('kolab_grp')           do setcode do 'root'                                    end end
Facter.add('kolab_rusr')          do setcode do 'root'                                    end end
Facter.add('kolab_rgrp')          do setcode do 'root'                                    end end
Facter.add('kolab_musr')          do setcode do 'root'                                    end end
Facter.add('kolab_mgrp')          do setcode do 'root'                                    end end


# Overwrite any operating specific values here

if Facter.operatingsystem == 'Gentoo'
  Facter.add('kolab_confscript')    do setcode do Facter.sbindir + '/pardalys'              end end
end
