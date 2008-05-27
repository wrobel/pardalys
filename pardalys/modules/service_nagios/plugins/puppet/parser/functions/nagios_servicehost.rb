# Return the nagios servicehost
module Puppet::Parser::Functions
  newfunction(:nagios_servicehost, :type => :rvalue) do |args|
    return args[0].split('|')[1]
  end
end
