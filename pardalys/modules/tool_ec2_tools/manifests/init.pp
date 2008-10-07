import 'root'
import 'os_gentoo'

# Class tool::ec2::tools
#
#  Provides tools for Amazons EC2
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_ec2_tools
#
class tool::ec2::tools {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { 'ec2-ami-tools':
        context  => 'tools_ec2_tools_ec2_ami_tools',
        package  => 'sys-cluster/ec2-ami-tools',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'ec2-ami-tools':
        category => 'sys-cluster',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_Keywords['ec2-ami-tools'];
      }
      gentoo_keywords { 'ec2-api-tools':
        context  => 'tools_ec2_tools_ec2_api_tools',
        package  => 'sys-cluster/ec2-api-tools',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'ec2-api-tools':
        category => 'sys-cluster',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_Keywords['ec2-api-tools'];
      }
      gentoo_keywords { 'amazon-ec2':
        context  => 'tools_ec2_tools_amazon_ec2',
        package  => 'dev-ruby/amazon-ec2',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'amazon-ec2':
        category => 'dev-ruby',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_Keywords['amazon-ec2'];
      }
      package { 'hpricot':
        category => 'dev-ruby',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      gentoo_keywords { 'aws-s3':
        context  => 'tools_ec2_tools_aws_s3',
        package  => 'dev-ruby/aws-s3',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'aws-s3':
        category => 'dev-ruby',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_Keywords['aws-s3'];
      }
      gentoo_keywords { 'aws-sdb':
        context  => 'tools_ec2_tools_aws_sdb',
        package  => 'dev-ruby/aws-sdb',
        keywords => "~$keyword",
        tag      => 'buildhost'
      }
      package { 'aws-sdb':
        category => 'dev-ruby',
        ensure   => 'installed',
        tag      => 'buildhost',
        require  => Gentoo_Keywords['aws-sdb'];
      }
    }
  }
}
