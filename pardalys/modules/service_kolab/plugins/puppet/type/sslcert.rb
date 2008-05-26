Puppet::Type.newtype(:sslcert) do
    @doc = "Create a self signed SSL certificate if there is none."

    ensurable

    newparam(:path, :namevar => true) do
        desc "The full path to the SSL certificate directory."
    end

    newparam(:hostname) do
        desc "The hostname."
    end

    newparam(:group) do
        desc "The group to which the files will be readable."
    end
end
