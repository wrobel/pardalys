# Determine the keyword of the system

Facter.add('keyword') do
  setcode do
    `/usr/bin/portageq envvar ACCEPT_KEYWORDS`
  end
end
