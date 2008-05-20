# Generate a list of version information variables
packages = '/etc/puppet/package_versions'

if FileTest.exists?(packages)
  File.readlines(packages).each do |l|
    pkg = l.split(':')
    Facter.add('version_' + pkg[0]) do
      setcode do
        version = `/usr/bin/eix --nocolor --format "<installedversionsshort>" --pure-packages --exact --category-name #{pkg[1]}`.chomp
	version = $1 if version =~ /^(.*)\[\?\]/
	version
      end
    end
  end
end
