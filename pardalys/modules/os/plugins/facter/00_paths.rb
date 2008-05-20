# Set basic system paths

if Facter.operatingsystem == 'Gentoo'
  Facter.add('sysconfdir')    do setcode do '/etc'                        end end
  Facter.add('sbindir')       do setcode do '/usr/sbin'                   end end
  Facter.add('bindir')        do setcode do '/usr/bin'                    end end
  Facter.add('localstatedir') do setcode do '/var'                        end end
  Facter.add('sysrundir')     do setcode do Facter.localstatedir + '/run' end end
  Facter.add('statelibdir')   do setcode do Facter.localstatedir + '/lib' end end
  Facter.add('logdir')        do setcode do Facter.localstatedir + '/log' end end
else
  Facter.add('sysconfdir')    do setcode do '/etc'                        end end
  Facter.add('sbindir')       do setcode do '/usr/sbin'                   end end
  Facter.add('bindir')        do setcode do '/usr/bin'                    end end
  Facter.add('localstatedir') do setcode do '/var'                        end end
  Facter.add('sysrundir')     do setcode do Facter.localstatedir + '/run' end end
  Facter.add('statelibdir')   do setcode do Facter.localstatedir + '/lib' end end
  Facter.add('logdir')        do setcode do Facter.localstatedir + '/log' end end
end
