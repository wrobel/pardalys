Puppet::Type.type(:sslcert).provide(:kolab) do
  desc "Provide a self signed certificate for a Kolab server."

  def create
    hostname = @resource[:hostname]
    confdir  = @resource[:path]
    group    = @resource[:group]

    # FIXME: This is of course a bad approach for generating the CA
    #        and the certificate. It should rather be done using the
    #        OpenSSL library Ruby provides. But as that would require
    #        writing new code it is something that needs to get fixed
    #        later.
    `/usr/bin/kolab_ca -newca #{hostname}`
    `/usr/bin/kolab_ca -newkey #{hostname} #{confdir}/key.pem`
    `/usr/bin/kolab_ca -newreq #{hostname} #{confdir}/key.pem #{confdir}/newreq.pem`
    `/usr/bin/kolab_ca -sign #{confdir}/newreq.pem #{confdir}/cert.pem`
    `chgrp #{group} #{confdir}/key.pem`
    `chmod 0640 #{confdir}/key.pem`
    `chgrp #{group} #{confdir}/cert.pem`
    `chmod 0640 #{confdir}/cert.pem`
  end

  def destroy
    File.unlink(@resource[:path] + '/key.pem')
    File.unlink(@resource[:path] + '/cert.pem')
  end

  def exists?
    File.exists?(@resource[:path] + '/cert.pem') and File.exists?(@resource[:path] + '/key.pem')
  end
end
