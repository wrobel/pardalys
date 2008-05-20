# Determine the keyword of the system

Facter.add('keyword') do
  setcode do
    if Facter.operatingsystem == 'Gentoo'
      `/usr/bin/portageq envvar ACCEPT_KEYWORDS`
    else
      false
    end
  end
end
