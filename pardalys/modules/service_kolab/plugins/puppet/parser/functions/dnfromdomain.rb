# Convert a domain/hostname to an LDAP base dn
module Puppet::Parser::Functions
  newfunction(:dnfromdomain, :type => :rvalue) do |args|
    base_dn = ''
    args[0].split('.').each do |domaincomp| 
      if base_dn != ''
        base_dn = base_dn + ',dc=' + domaincomp
      else
        base_dn = base_dn + 'dc=' + domaincomp
      end
    end
    return base_dn
  end
end
