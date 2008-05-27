# Return the nagios hostalias
module Puppet::Parser::Functions
  newfunction(:nagios_hostalias, :type => :rvalue) do |args|
    return args[0].split('|')[2]
  end
end
