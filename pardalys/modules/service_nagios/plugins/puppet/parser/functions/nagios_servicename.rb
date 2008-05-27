# Return the nagios servicename
module Puppet::Parser::Functions
  newfunction(:nagios_servicename, :type => :rvalue) do |args|
    return args[0].split('|')[0]
  end
end
