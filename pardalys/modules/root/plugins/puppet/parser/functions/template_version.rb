require 'puppet/util/autoload'

# Return the matching template version
module Puppet::Parser::Functions
  newfunction(:template_version, :type => :rvalue) do |args|
    if not args or not args[0]
      raise Puppet::ParseError, "No package version has been provided!"
    end
    if not args[1]
      raise Puppet::ParseError, "No mappings provided!"
    end
    tversion = nil
    args[1].split(',').each do |tv|
      convert = tv.split(':')
      if convert[0].split('@').include?(args[0])
        tversion = convert[1]
        break
      end
    end
    if not tversion and args.length == 3
      tversion = args[2]
    elsif not tversion
      raise Puppet::ParseError, "Unknown package version!"
    end
    return tversion
  end
end
