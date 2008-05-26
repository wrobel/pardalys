# Get the Kolab settings for our system

if FileTest.file?(Facter.kolab_globalsfile)
  facts = {}
  File.open(Facter.kolab_globalsfile).each do |line|
    var = $1 and value = $2 if line =~ /^([^#].+):(.+)$/
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

if FileTest.file?(Facter.kolab_configfile)
  facts = {}
  File.open(Facter.kolab_configfile).each do |line|
    var = $1 and value = $2 if line =~ /^([^#].+):(.+)$/
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
    var = $1 and value = $2 if line =~ /^([^#].+):(.+)$/
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

if !Facter.method_defined? 'kolab_fqdnhostname'
  Facter.add('kolab_fqdnhostname') do
    setcode do
      Facter.hostname
    end
  end
end

if !Facter.method_defined? 'kolab_is_master'
  Facter.add('kolab_is_master') do
    setcode do
      true
    end
  end
end

if !Facter.method_defined? 'kolab_postfix_mydomain'
  Facter.add('kolab_postfix_mydomain') do
    setcode do
      Facter.kolab_fqdnhostname
    end
  end
end

def dnfromdomain(domain)
  base_dn = ''
  domain.split('.').each do |domaincomp| 
    if base_dn != ''
      base_dn = base_dn + ',dc=' + domaincomp
    else
      base_dn = base_dn + 'dc=' + domaincomp
    end
  end
  return base_dn
end

if !Facter.method_defined? 'kolab_base_dn'
  Facter.add('kolab_base_dn') do
    setcode do
      dnfromdomain(Facter.kolab_postfix_mydomain)
    end
  end
end

if !Facter.method_defined? 'kolab_bind_dn'
  Facter.add('kolab_bind_dn') do
    setcode do
      'cn=manager,cn=internal,' + Facter.kolab_base_dn
    end
  end
end

if !Facter.method_defined? 'kolab_bind_pw'
  Facter.add('kolab_bind_pw') do
    setcode do
      `#{Facter.bindir}/openssl rand -base64 12`
    end
  end
  Facter.add('kolab_bind_pw_hash') do
    setcode do
      bind_pw_sq = Facter.kolab_bind_pw.gsub('/([\\"$]/','\\\1')
      `#{Facter.sbindir}/slappasswd -s #{bind_pw_sq}`
    end
  end
end

if !Facter.method_defined? 'kolab_bind_pw_hash'
  Facter.add('kolab_bind_pw_hash') do
    setcode do
      bind_pw_sq = Facter.kolab_bind_pw.gsub('/([\\"$]/','\\\1')
      `#{Facter.sbindir}/slappasswd -s #{bind_pw_sq}`
    end
  end
end

if !Facter.method_defined? 'kolab_ldap_uri'
  Facter.add('kolab_ldap_uri') do
    setcode do
      'ldap://127.0.0.1:389'
    end
  end
end

if !Facter.method_defined? 'kolab_ldap_master_uri'
  Facter.add('kolab_ldap_master_uri') do
    setcode do
      'ldap://127.0.0.1:389'
    end
  end
end

if !Facter.method_defined? 'kolab_php_dn'
  Facter.add('kolab_php_dn') do
    setcode do
      'cn=nobody,cn=internal,' + Facter.kolab_base_dn
    end
  end
end

if !Facter.method_defined? 'kolab_php_pw'
  Facter.add('kolab_php_pw') do
    setcode do
      `#{Facter.bindir}/openssl rand -base64 30`
    end
  end
end

if !Facter.method_defined? 'kolab_calendar_id'
  Facter.add('kolab_calendar_id') do
    setcode do
      'calendar'
    end
  end
end

if !Facter.method_defined? 'kolab_calendar_pw'
  Facter.add('kolab_calendar_pw') do
    setcode do
      `#{Facter.bindir}/openssl rand -base64 30`
    end
  end
end

require ldap

host = lookupvar('kolab_ldap_uri').split('://')[1]
(server, port) = host.split(':')
@connection = LDAP::Conn.new(server, port)
@connection.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
@connection.set_option(LDAP::LDAP_OPT_REFERRALS, LDAP::LDAP_OPT_ON)
@connection.simple_bind(lookupvar('kolab_bind_dn'), lookupvar('kolab_bind_pw'))

base_dn = lookupvar('kolab_base_dn')

kolab = @connection.search('k=kolab,' + base_dn, 'one', '(objectclass=kolab)')

kolab.each do |key, val|
  Facter.add(key) = val
end
