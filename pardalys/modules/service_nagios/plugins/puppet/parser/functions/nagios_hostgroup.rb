# Return the nagios hostgroup
module Puppet::Parser::Functions
  newfunction(:nagios_hostgroup, :type => :rvalue) do |args|
    return args[0].split('|')[3]
  end
end
