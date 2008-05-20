# Evaluate the value of a variable that might have been defined globally.

module Puppet::Parser::Functions
  newfunction(:get_var, :type => :rvalue) do |args|
    var = args[0]
    global_var = lookupvar(var)
    if global_var != ""
      return global_var
    end
    if args.length > 1
      return args[1]
    end
    return ""
  end
end
