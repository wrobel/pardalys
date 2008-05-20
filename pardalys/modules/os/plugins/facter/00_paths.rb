# Set basic system paths

if Facter.operatingsystem == 'Gentoo'
  Facter.add('sysconfdir')    do setcode do '/etc'                        end
  Facter.add('localstatedir') do setcode do '/var'                        end
  Facter.add('sysrundir')     do setcode do Facter.localstatedir + '/run' end
  Facter.add('statelibdir')   do setcode do Facter.localstatedir + '/lib' end
  Facter.add('logdir')        do setcode do Facter.localstatedir + '/log' end
else
  Facter.add('sysconfdir')    do setcode do '/etc'                        end
  Facter.add('localstatedir') do setcode do '/var'                        end
  Facter.add('sysrundir')     do setcode do Facter.localstatedir + '/run' end
  Facter.add('statelibdir')   do setcode do Facter.localstatedir + '/lib' end
  Facter.add('logdir')        do setcode do Facter.localstatedir + '/log' end
end
