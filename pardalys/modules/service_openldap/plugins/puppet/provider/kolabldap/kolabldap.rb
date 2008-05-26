Puppet::Type.type(:kolabldap).provide(:kolab) do
  desc "Generate the basic LDAP structure on a Kolab server."

  def create
    unless Puppet.features.ldap?
      raise Puppet::Error, "Could not set up LDAP Connection: Missing ruby/ldap libraries"
    end
    host = @resource[:uri].split('://')[1]
    (server, port) = host.split(':')
    @connection = LDAP::Conn.new(server, port.to_i)
    @connection.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @connection.set_option(LDAP::LDAP_OPT_REFERRALS, LDAP::LDAP_OPT_ON)
    @connection.simple_bind(@resource[:binddn], @resource[:passwd])

    base_dn = @resource[:basedn]

    if not @connection.search(base_dn, 'exact', '(objectclass=*)')
      (dc, dp) = base_dn.split(',')[0].split('=')
      base_obj = {dc => dp, 'objectclass'=> ['top', 'domain'] }
      @connection.add(base_dn, base_obj)
    end
    kolab_obj = {
      'k' => 'kolab',
      #FIXME
      'kolabhost' => '',
      #FIXME
      'postfix-mydomain' => '',
      #FIXME
      'postfix-myddestination' => '',
      #FIXME
      'postfix-mynetworks' => '',
      'postfix-enable-virus-scan' => "TRUE",
      'cyrus-autocreatequota' => 100000,
      'cyrus-quotawarn' => 80,
      'cyrus-admins' => "manager",
      'cyrus-imap' => "TRUE",
      'cyrus-pop3' => "FALSE",
      'cyrus-imaps' => "TRUE",
      'cyrus-pop3s' => "TRUE",
      'cyrus-sieve' => "TRUE",
      'apache-http' => "FALSE",
      'apache-allow-unauthenticated-fb' => "FALSE",
      'uid' => "freebusy",
      'userPassword' => "freebusy",
      'objectclass' => ['top', 'kolab' ]
    }
    @connection.add('k=kolab,' + base_dn, kolab_obj)

    @connection.add('cn=internal,' + base_dn, {'cn' => 'internal', 'objectclass' => ['top','kolabnamedobject']})
    int_dn = 'cn=internal,' + base_dn
    ['cn=domains,', 'cn=external,', 'cn=resources,', 'cn=groups,'].each do |dnc|
      @connection.add(dnc + int_dn, {dnc.split('=')[0] => dnc.split('=')[1], 'objectclass' => ['top','kolabnamedobject']})
    end
      
  end

  def destroy
  end

  def exists?
    false
  end
end
