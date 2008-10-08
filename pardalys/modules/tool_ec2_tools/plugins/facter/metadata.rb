# Copyright 2008 Tim Dysinger
# http://www.opensource.org/licenses/mit-license.php
require 'open-uri'

def metadata(id='')
  open("http://169.254.169.254/2008-02-01/meta-data/#{id}").read.
    split("\n").each do |o|
    key = "#{id}#{o.gsub(/\=.*$/, '/')}"
    if key[-1..-1] != '/'
      Facter.add("ec2_#{key.gsub(/\-|\//, '_')}".to_sym) do
        setcode do
          value = open("http://169.254.169.254/2008-02-01/meta-data/#{key}").
            read.split("\n")
          value = value.size > 1 ? value : value.first
        end
      end
    else
      metadata(key)
    end
  end
end

metadata

Facter.add(:ec2_instance_cpu) do
  setcode do
    case Facter.value(:ec2_instance_type)
    when 'm1.small'  ; 'athlon-xp'
    when 'm1.large'  ; 'opteron'
    when 'm1.xlarge' ; 'opteron'
    when 'c1.medium' ; 'prescott'
    when 'c1.xlarge' ; 'nocona'
    end
  end
end
