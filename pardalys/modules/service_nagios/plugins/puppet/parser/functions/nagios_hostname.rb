# Return the nagios hostname
module Puppet::Parser::Functions
  newfunction(:nagios_hostname, :type => :rvalue) do |args|
    return args[0].split('|')[0]
  end
end
