# Return the nagios hostip
module Puppet::Parser::Functions
  newfunction(:nagios_hostip, :type => :rvalue) do |args|
    return args[0].split('|')[1]
  end
end
