# Get the Kolab settings for our system

if Facter.operatingsystem
  core_config = File.dirname(__FILE__) + '/dist_conf/' + Facter.operatingsystem + '.rb'
  if FileTest.file?(core_config)
    require core_config
  else
    puts "File #{core_config} missing."
    puts "Operating system #{Facter.operatingsystem} not supported!"
    exit
  end
else
  puts "Facter did not deliver any 'operatingsystem' value."
  puts "Unknown operating system!"
  exit
end

if FileTest.file?($facts['globalsfile'])
  File.open($facts['globalsfile']).each do |line|
    var = $1 and value = $2 if line =~ /^([^#][^:]+):(.+)$/
    if var != nil && value != nil
      $facts[var.strip()] = value.strip()
      var = nil
      value = nil
    end
  end
end

if !$facts['configfile']
  $facts['configfile'] = $facts['confdir'] + '/kolab.conf'
end

if FileTest.file?($facts['configfile'])
  File.open($facts['configfile']).each do |line|
    var = $1 and value = $2 if line =~ /^([^#][^:]+):(.+)$/
    if var != nil && value != nil
      $facts[var.strip()] = value.strip()
      var = nil
      value = nil
    end
  end
end

if !$facts['bootstrapfile']
  $facts['bootstrapfile'] = $facts['confdir'] + '/kolab.bootstrap'
end

if FileTest.file?($facts['bootstrapfile'])
  File.open($facts['bootstrapfile']).each do |line|
    var = $1 and value = $2 if line =~ /^([^#][^:]+):(.+)$/
    if var != nil && value != nil
      $facts[var.strip()] = value.strip()
      var = nil
      value = nil
    end
  end
  $facts['bootstrap'] = true
else
  $facts['bootstrap'] = false
end

if !$facts.keys.include? 'fqdnhostname'
  $facts['fqdnhostname'] = Facter.hostname
end

if !$facts.keys.include? 'is_master'
  $facts['is_master'] = true
end

if !$facts.keys.include? 'postfix_mydomain'
  $facts['postfix_mydomain'] = $facts['fqdnhostname']
end

if !$facts.keys.include? 'admin_mail'
  $facts['admin_mail'] = 'hostmaster@' + $facts['postfix_mydomain']
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

if !$facts.keys.include? 'base_dn'
  $facts['base_dn'] = dnfromdomain($facts['postfix_mydomain'])
end

if !$facts.keys.include? 'bind_dn'
  $facts['bind_dn'] = 'cn=manager,cn=internal,' + $facts['base_dn']
end

if !$facts.keys.include? 'bind_pw'
  if FileTest.file?($facts['bindir'] + '/openssl')
    $facts['bind_pw'] = `#{$facts['bindir']}/openssl rand -base64 12`
    bind_pw_sq = $facts['bind_pw'].gsub('/([\\"$]/','\\\1')
  else 
    bind_pw_sq = ''
  end
end

if !$facts.keys.include? 'bind_pw_hash'
  if FileTest.file?($facts['bindir'] + '/slappasswd')
    bind_pw_sq = $facts['bind_pw'].gsub('/([\\"$]/','\\\1')
    $facts['bind_pw_hash'] = `#{$facts['sbindir']}/slappasswd -s #{bind_pw_sq}`
  else
    $facts['bind_pw_hash'] = ''
  end
end

if !$facts.keys.include? 'ldap_uri'
  $facts['ldap_uri'] = 'ldap://127.0.0.1:389'
end

if !$facts.keys.include? 'ldap_master_uri'
  $facts['ldap_master_uri'] = 'ldap://127.0.0.1:389'
end

# Rewrite the older kolab_php_dn into the newer variable names
if $facts.keys.include? 'php_dn'
  $facts['bind_dn_restricted'] = $facts['php_dn']
end

# Rewrite the older kolab_php_pw into the newer variable names
if $facts.keys.include? 'php_pw'
  $facts['bind_pw_restricted'] = $facts['php_pw']
end

if !$facts.keys.include? 'bind_dn_restricted'
  $facts['bind_dn_restricted'] = 'cn=nobody,cn=internal,' + $facts['base_dn']
end

if !$facts.keys.include? 'bind_pw_restricted'
  if FileTest.file?($facts['bindir'] + '/openssl')
    $facts['bind_pw_restricted'] = `#{$facts['bindir']}/openssl rand -base64 30`
  else 
    $facts['bind_pw_restricted'] = ''
  end
end

if !$facts.keys.include? 'calendar_id'
  $facts['calendar_id'] = 'calendar'
end

if !$facts.keys.include? 'calendar_pw'
  if FileTest.file?($facts['bindir'] + '/openssl')
    $facts['calendar_pw'] = `#{$facts['bindir']}/openssl rand -base64 30`
  else
    $facts['calendar_pw'] = ''
  end
end

ldap_present = false

begin
  require 'ldap'
  ldap_present = true
rescue Exception
  Puppet.debug "Failed to load ruby/ldap library!"
end

if ldap_present

  host = $facts['ldap_uri'].split('://')[1]
  (server, port) = host.split(':')
  base_dn = $facts['base_dn']

  kolab = nil

  begin
    @connection = LDAP::Conn.new(server, port.to_i)
    
    @connection.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @connection.set_option(LDAP::LDAP_OPT_REFERRALS, LDAP::LDAP_OPT_ON)
    @connection.simple_bind($facts['bind_dn'], $facts['bind_pw'])
    kolab_obj = @connection.search2(base_dn, LDAP::LDAP_SCOPE_ONELEVEL, '(&(objectclass=kolab)(k=kolab))')
  rescue Exception => e
    if not $facts['bootstrap']
      $facts['ldap_error'] = e.to_s
    end
  end

  if kolab_obj
    $facts['ldap_error'] = false
    kolab_obj.each do |entry|
      entry.each_pair do |key, val|
        akey = key.gsub(/-/, '_')
        if val[0] == 'TRUE'
          $facts[akey] = true
        elsif val[0] == 'FALSE'
          $facts[akey]  = false
        else
          $facts[akey]  = val.join(',')
        end
      end
    end

    imap_groups = ''
    gid = 60000

    groups = @connection.search2(base_dn, LDAP::LDAP_SCOPE_SUBTREE, '(&(mail=*)(objectclass=kolabgroupofnames))')
    groups.each do |entry|
      members = []
      entry['member'].to_ary.each do |dn|
        member = @connection.search2(dn, LDAP::LDAP_SCOPE_BASE, '(objectclass=*)')
        if member and member[0]['mail']
          members << member[0]['mail']
        elsif member and member[0]['uid']
          members << member[0]['uid']
        end
      end
      if members
        imap_groups << [ entry['mail'], '*', gid,  members.join(',')].join(':') + "\n"
        gid = gid + 1
      end
    end
    if imap_groups
      $facts['imap_groups'] = imap_groups
    end
  end
end

$facts.each{|var,val|
  Facter.add('kolab_' + var) do
    if val == 'TRUE'
      val = true
    elsif val == 'FALSE'
      val = false
    end
    setcode do
      val
    end
  end
}
