import 'tool_ec2_kernel'
import 'tool_ec2_tools'
import 'tool_fs'
import 'tool_ntp'

# Class meta::de::pardus::ec2
#
#  Defines the setup for a ec2 instance.
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package meta_de_pardus_ec2
#
class meta::de::pardus::ec2 {

  include tool::ec2::kernel
  include tool::ec2::tools
  include tool::fs
  include tool::ntp

}
