# Return the nagios servicecheck
module Puppet::Parser::Functions
  newfunction(:nagios_servicecheck, :type => :rvalue) do |args|
    return args[0].split('|')[3]
  end
end
