# Return the nagios servicedesc
module Puppet::Parser::Functions
  newfunction(:nagios_servicedesc, :type => :rvalue) do |args|
    return args[0].split('|')[2]
  end
end
