# Generate a list of version information variables

packages = File.dirname(__FILE__) + '/../etc/package_versions'
if !FileTest.exists?(packages)
  packages = '/etc/puppet/package_versions'
end

if FileTest.exists?(packages)
  File.readlines(packages).each do |l|
    pkgname = ''
    p = l.split(':')
    package = p.shift()
    p.each do |q|
      (pkgname, os) = q.split('@')
      if os = Facter.operatingsystem
        break
      end
    end
    if pkgname
      Facter.add('version_' + package) do
        setcode do
          if Facter.operatingsystem == 'Gentoo'
            version = `/usr/bin/eix --nocolor --format "<installedversionsshort>" --pure-packages --exact --category-name #{pkgname}`.chomp
            version = $1 if version =~ /^(.*)\[\?\]/
            version
          else
            false
          end
        end
      end
    end
  end
end
