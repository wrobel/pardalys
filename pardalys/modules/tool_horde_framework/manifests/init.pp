import 'os_gentoo'

# Class tool::horde::framework
#
#  Provides the horde framework
#
# @author Gunnar Wrobel <p@rdus.de>
# @version 1.0
# @package tool_horde_framework
#
class tool::horde::framework {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      gentoo_keywords { 'Horde_Framework':
        context => 'tool_horde_framework_Horde_Framework',
        package => '=dev-php/Horde_Framework-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_LDAP':
        context => 'tool_horde_framework_Horde_LDAP',
        package => '=dev-php/Horde_LDAP-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_MIME':
        context => 'tool_horde_framework_Horde_MIME',
        package => '=dev-php/Horde_MIME-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_DOM':
        context => 'tool_horde_framework_Horde_DOM',
        package => '=dev-php/Horde_DOM-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Serialize':
        context => 'tool_horde_framework_Horde_Serialize',
        package => '=dev-php/Horde_Serialize-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Date':
        context => 'tool_horde_framework_Horde_Date',
        package => '=dev-php/Horde_Date-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Browser':
        context => 'tool_horde_framework_Horde_Browser',
        package => '=dev-php/Horde_Browser-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Cipher':
        context => 'tool_horde_framework_Horde_Cipher',
        package => '=dev-php/Horde_Cipher-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Cache':
        context => 'tool_horde_framework_Horde_Cache',
        package => '=dev-php/Horde_Cache-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_History':
        context => 'tool_horde_framework_Horde_History',
        package => '=dev-php/Horde_History-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_NLS':
        context => 'tool_horde_framework_Horde_NLS',
        package => '=dev-php/Horde_NLS-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Secret':
        context => 'tool_horde_framework_Horde_Secret',
        package => '=dev-php/Horde_Secret-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_DataTree':
        context => 'tool_horde_framework_Horde_DataTree',
        package => '=dev-php/Horde_DataTree-0.0.3',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_SessionObjects':
        context => 'tool_horde_framework_Horde_SessionObjects',
        package => '=dev-php/Horde_SessionObjects-0.0.2',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Auth':
        context => 'tool_horde_framework_Horde_Auth',
        package => '=dev-php/Horde_Auth-0.1.1',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Group':
        context => 'tool_horde_framework_Horde_Group',
        package => '=dev-php/Horde_Group-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Util':
        context => 'tool_horde_framework_Horde_Util',
        package => '=dev-php/Horde_Util-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_iCalendar':
        context => 'tool_horde_framework_Horde_iCalendar',
        package => '=dev-php/Horde_iCalendar-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Horde_Perms':
        context => 'tool_horde_framework_Horde_Perms',
        package => '=dev-php/Horde_Perms-0.1.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_Server':
        context => 'tool_horde_framework_Kolab_Server',
        package => '=dev-php/Horde_Kolab_Server-0.3.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_Format':
        context => 'tool_horde_framework_Kolab_Format',
        package => '=dev-php/Horde_Kolab_Format-1.0.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      gentoo_keywords { 'Kolab_Storage':
        context => 'tool_horde_framework_Kolab_Storage',
        package => '=dev-php/Horde_Kolab_Storage-0.3.0',
        keywords => "~$keyword",
        tag     => 'buildhost'
      }
      package { 'Horde_Kolab_Storage':
        category => 'dev-php',
        ensure   => 'installed',
        require  => [ Gentoo_keywords['Kolab_Storage'],
                      Gentoo_keywords['Kolab_Format'],
                      Gentoo_keywords['Kolab_Server'],
                      Gentoo_keywords['Horde_Perms'],
                      Gentoo_keywords['Horde_iCalendar'],
                      Gentoo_keywords['Horde_Util'],
                      Gentoo_keywords['Horde_Group'],
                      Gentoo_keywords['Horde_Auth'],
                      Gentoo_keywords['Horde_SessionObjects'],
                      Gentoo_keywords['Horde_DataTree'],
                      Gentoo_keywords['Horde_Secret'],
                      Gentoo_keywords['Horde_NLS'],
                      Gentoo_keywords['Horde_History'],
                      Gentoo_keywords['Horde_Cache'],
                      Gentoo_keywords['Horde_Cipher'],
                      Gentoo_keywords['Horde_Browser'],
                      Gentoo_keywords['Horde_Date'],
                      Gentoo_keywords['Horde_Serialize'],
                      Gentoo_keywords['Horde_DOM'],
                      Gentoo_keywords['Horde_MIME'],
                      Gentoo_keywords['Horde_LDAP'],
                      Gentoo_keywords['Horde_Framework']],
        tag      => 'buildhost';
      }
    }
    default:
    {
      package { php:
        ensure   => 'installed',
      }
    }
  }
}
