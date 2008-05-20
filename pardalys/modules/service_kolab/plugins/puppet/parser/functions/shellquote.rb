# Quote strings for shell use
module Puppet::Parser::Functions
  newfunction(:shellquote, :type => :rvalue) do |args|
    return args[0].gsub('/([\\"$]/','\\\1')
  end
end
