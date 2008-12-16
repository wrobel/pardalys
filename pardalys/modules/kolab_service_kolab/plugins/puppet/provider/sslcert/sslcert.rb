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
    `mkdir -p #{confdir}`
    `/usr/bin/kolab_ca -newca #{hostname}`
    `/usr/bin/kolab_ca -newkey #{hostname} #{confdir}/server.key`
    `/usr/bin/kolab_ca -newreq #{hostname} #{confdir}/server.key #{confdir}/server.newreq`
    `/usr/bin/kolab_ca -sign #{confdir}/server.newreq #{confdir}/server.crt`
    `rm #{confdir}/server.newreq`
    `chgrp #{group} #{confdir}/server.key`
    `chmod 0640 #{confdir}/server.key`
    `chgrp #{group} #{confdir}/server.crt`
    `chmod 0640 #{confdir}/server.crt`
    `cat #{confdir}/server.crt > #{confdir}/server.pem`
    `cat #{confdir}/server.key >> #{confdir}/server.pem`
    `chgrp #{group} #{confdir}/server.pem`
    `chmod 0640 #{confdir}/server.pem`
  end

  def destroy
    File.unlink(@resource[:path] + '/server.crt')
    File.unlink(@resource[:path] + '/server.key')
    File.unlink(@resource[:path] + '/server.pem')
  end

  def exists?
    File.exists?(@resource[:path] + '/server.pem') and File.exists?(@resource[:path] + '/server.crt') and File.exists?(@resource[:path] + '/server.key')
  end
end
