import 'root'
import 'os_gentoo'
import 'os_ubuntu'

# Class tool::ec2::tools
#
#  Provides tools for Amazons EC2.
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
      gentoo_keywords { 'xml-simple':
        context  => 'tools_ec2_tools_xml_simple',
        package  => 'dev-ruby/xml-simple',
        keywords => "~$keyword",
        tag      => 'buildhost'
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
        require  => [Gentoo_Keywords['amazon-ec2'],
                     Gentoo_Keywords['xml-simple']];
      }
      package { 'hpricot':
        category => 'dev-ruby',
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      gentoo_keywords { 'mime-types':
        context  => 'tools_ec2_tools_mime_types',
        package  => 'dev-ruby/mime-types',
        keywords => "~$keyword",
        tag      => 'buildhost'
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
        require  => [Gentoo_Keywords['aws-s3'],
                     Gentoo_Keywords['mime-types'],
                     Gentoo_Keywords['xml-simple']];
      }
      gentoo_keywords { 'uuidtools':
        context  => 'tools_ec2_tools_uuidtools',
        package  => 'dev-ruby/uuidtools',
        keywords => "~$keyword",
        tag      => 'buildhost'
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
        require  => [Gentoo_Keywords['aws-sdb'],
                     Gentoo_Keywords['uuidtools']];
      }

      package { 's3fs':
        category => 'sys-fs',
        ensure   => 'installed',
        tag      => 'buildhost',
      }

      file {
        '/usr/bin/binpkg-rsync.sh':
        source => 'puppet:///modules/tool_ec2_tools/binpkg-rsync.sh',
        mode   => 755;
      }


      @line {'local_start_ec2_access':
        file => '/etc/conf.d/local.start',
        line => '/usr/bin/ec2-init.sh',
        tag => 'buildhost'
      }
    }
    ubuntu:
    {
      include ubuntu::repositories::multiverse

      realize File[multiverse_list]

      package { 'ec2-ami-tools': ensure   => 'installed' }
      package { 'ec2-api-tools': ensure   => 'installed' }
      package { libhpricot-ruby: ensure => 'installed' }
      package { libamazon-ruby: ensure => 'installed' }
      package { libright-aws-ruby: ensure => 'installed' }
      package { 's3fs': ensure   => 'installed' }
      package { aws-sdb:
        ensure   => 'installed',
        provider => 'gem'
      }
      package { amazon-ec2:
        ensure => 'installed',
        provider => 'gem'
      }
      package { aws-s3:
        ensure => 'installed',
        provider => 'gem'
      }
    }
  }
  file {
    '/usr/bin/ec2-init.sh':
    source => 'puppet:///modules/tool_ec2_tools/ec2-init.sh',
    owner => 'root',
    group => 'root',
    mode   => 755;
    '/usr/bin/ec2-get-metadata.sh':
    source => 'puppet:///modules/tool_ec2_tools/ec2-get-metadata.sh',
    owner => 'root',
    group => 'root',
    mode   => 755;
    '/usr/bin/ec2-import-sshkeys.sh':
    source => 'puppet:///modules/tool_ec2_tools/ec2-import-sshkeys.sh',
    owner => 'root',
    group => 'root',
    mode   => 755;
  }
}
