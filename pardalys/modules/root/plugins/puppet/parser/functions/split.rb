# Return an array by splitting a variable
module Puppet::Parser::Functions
  newfunction(:split, :type => :rvalue) do |args|
    return args[0].split(args[1])
  end
end
