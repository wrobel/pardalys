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

    begin
      @connection.search2(base_dn, LDAP::LDAP_SCOPE_ONELEVEL, '(objectclass=*)')
    rescue Exception => e
      (dc, dp) = base_dn.split(',')[0].split('=')
      ldap_object = {dc => [dp], 'objectclass'=> ['top', 'domain'] }
      mod = []
      ldap_object.each do |key, val|
        mod.push(LDAP::Mod.new(LDAP::LDAP_MOD_ADD, key, val))
      end
      @connection.add(base_dn, mod)
    end

    begin
      @connection.search2('k=kolab,' + base_dn, LDAP::LDAP_SCOPE_ONELEVEL, '(objectclass=*)')
    rescue Exception => e
      kolab_object = {
        'k' => ['kolab'],
        #FIXME
        #'kolabHost' => [''],
        #FIXME
        #'postfix-mydomain' => [''],
        #FIXME
        #'postfix-mydestination' => [''],
        #FIXME
        #'postfix-mynetworks' => [''],
        'postfix-enable-virus-scan' => ['TRUE'],
        'cyrus-autocreatequota' => ['100000'],
        'cyrus-quotawarn' => ['80'],
        'cyrus-admins' => ['manager'],
        'cyrus-imap' => ['TRUE'],
        'cyrus-pop3' => ['FALSE'],
        'cyrus-imaps' => ['TRUE'],
        'cyrus-pop3s' => ['TRUE'],
        'cyrus-sieve' => ['TRUE'],
        'apache-http' => ['FALSE'],
        'apache-allow-unauthenticated-fb' => ['FALSE'],
        'uid' => ['freebusy'],
        'userPassword' => ['freebusy'],
        'objectclass' => ['top', 'kolab' ]
      }
      mod = []
      kolab_object.each do |key, val|
        mod.push(LDAP::Mod.new(LDAP::LDAP_MOD_ADD, key, val))
      end
      @connection.add('k=kolab,' + base_dn, mod)
    end

    begin
      @connection.search2('cn=internal,' + base_dn, LDAP::LDAP_SCOPE_ONELEVEL, '(objectclass=*)')
    rescue Exception => e
      ldap_object = {'cn' => ['internal'], 'objectclass' => ['top','kolabnamedobject']}
      mod = []
      ldap_object.each do |key, val|
        mod.push(LDAP::Mod.new(LDAP::LDAP_MOD_ADD, key, val))
      end
      @connection.add('cn=internal,' + base_dn, mod)
    end

    int_dn = 'cn=internal,' + base_dn
    ['domains', 'external', 'resources', 'groups'].each do |dnc|
      begin
        @connection.search2(dnc + int_dn, LDAP::LDAP_SCOPE_ONELEVEL, '(objectclass=*)')
      rescue Exception => e
        ldap_object = {'cn' => [dnc], 'objectclass' => ['top','kolabnamedobject']}
        mod = []
        ldap_object.each do |key, val|
          mod.push(LDAP::Mod.new(LDAP::LDAP_MOD_ADD, key, val))
        end
        @connection.add('cn=' + dnc + ',' + int_dn, mod)
      end
    end
      
  end

  def destroy
  end

  def exists?
    false
  end
end
