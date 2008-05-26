Puppet::Type.newtype(:kolabldap) do
    @doc = "Create the basic Kolab LDAP structure."

    ensurable

    newparam(:uri, :namevar => true) do
        desc "The URI to the LDAP server."
    end

    newparam(:basedn) do
        desc "The base DN for the LDAP structure."
    end

    newparam(:binddn) do
        desc "The admin DN."
    end

    newparam(:passwd) do
        desc "The admin password."
    end


end
