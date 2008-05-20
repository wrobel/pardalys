require 'puppet/util/autoload'
# Return the matching template version
module Puppet::Parser::Functions
  newfunction(:template_version, :type => :rvalue) do |args|
    tversion = nil
    args[1].split(',').each do |tv|
      convert = tv.split(':')
      if convert[0].split('@').include?(args[0])
        tversion = convert[1]
        break
      end
    end
    if not tversion and args[2]
      send(:crit, 'Unknown package version! Returning default ' + args[2] + '.')
      tversion = args[2]
    elsif not tversion
      send(:crit, 'Unknown package version!')
      tversion = 'UNKNOWN'
    end
    return tversion
  end
end
