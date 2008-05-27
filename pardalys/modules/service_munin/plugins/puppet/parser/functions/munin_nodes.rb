# Return the munin nodes for munin.conf
module Puppet::Parser::Functions
  newfunction(:munin_nodes, :type => :rvalue) do |args|
    nodes = lookupvar('munin_nodes')
    result = ""
    nodes.split(',').each do |node|
      params = node.split('|')
      result = result + "[" + params[0] + "]\n"
      result = result + " address " + params[1] + "\n"
      result = result + " use_node_name yes\n"
      result = result + " df.notify_alias Disk usage\n"
    end
    return result
  end
end
