# Get the Kolab settings for our system

if FileTest.file?(Facter.kolab_configfile)
  facts = {}
  File.open(Facter.kolab_configfile).each do |line|
    var = $1 and value = $2 if line =~ /^(.+):(.+)$/
    if var != nil && value != nil
      facts[var.strip()] = value.strip()
      var = nil
      value = nil
    end
  end
  facts.each{|var,val|
    Facter.add('kolab_' + var) do
      setcode do
        val
      end
    end
  }
end

if FileTest.file?(Facter.kolab_bootstrapfile)
  facts = {}
  File.open(Facter.kolab_bootstrapfile).each do |line|
    var = $1 and value = $2 if line =~ /^(.+):(.+)$/
    if var != nil && value != nil
      facts[var.strip()] = value.strip()
      var = nil
      value = nil
    end
  end
  facts.each{|var,val|
    Facter.add('kolab_bootstrap_' + var) do
      setcode do
        val
      end
    end
  }
  Facter.add('kolab_bootstrap') do
    setcode do
      true
    end
  end
else
  Facter.add('kolab_bootstrap') do
    setcode do
      false
    end
  end
end

