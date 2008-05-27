#!/usr/bin/perl -w
use strict;
##########################################################################
# $Id: logwatch.pl,v 1.183 2006/12/20 16:41:24 kirk Exp $
##########################################################################
# Most current version can always be found at:
# ftp://ftp.logwatch.org/pub/redhat/RPMS

########################################################
# Specify version and build-date:
my $Version = '7.3.2';
my $VDate = '12/20/06';

#######################################################
# This was written and is maintained by:
#    Kirk Bauer <kirk@kaybee.org>
#
# Please send all comments, suggestions, bug reports,
#    etc, to logwatch@logwatch.org.
#
########################################################

# About the locale:  some functions use locale information.  In particular,
# Logwatch makes use of strftime, which makes use of LC_TIME variable.  Other
# functions may also use locale information.
#
# Because the parsing must be in the same locale as the logged information,
# and this appears to be "C", "POSIX", or "en_US", we set LC_ALL for
# this and other scripts invoked by this script.  We use "C" because it
# is always (?) available, whereas POSIX or en_US may not.  They all use
# the same time formats and rely on the ASCII character set.
#
# Variables REAL_LANG and REAL_LC_ALL keep the original values for use by
# scripts that need native language.
$ENV{'REAL_LANG'}=$ENV{'LANG'} if $ENV{'LANG'};
$ENV{'REAL_LC_ALL'}=$ENV{'LC_ALL'} if $ENV{'LC_ALL'};

# Setting ENV for scripts invoked by this script.
$ENV{'LC_ALL'} = "C";
# Using setlocale to set locale for this script.
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");

my $BaseDir = "/usr/share/logwatch";
my $ConfigDir = "/etc/logwatch";
my $PerlVersion = "$^X";

#############################################################################

use Getopt::Long;
use POSIX qw(uname);
use File::Temp qw/ tempdir /;

eval "use lib \"$BaseDir/lib\";";
eval "use Logwatch \':dates\'";

my (%Config, @ServiceList, @LogFileList, %ServiceData, %LogFileData);
my (@AllShared, @AllLogFiles, @FileList);
# These need to not be global variables one day
my (@ReadConfigNames, @ReadConfigValues);

# Default config here...
$Config{'detail'} = 0;
$Config{'mailto'} = "root";
$Config{'mailfrom'} = "Logwatch";
$Config{'save'} = "";
$Config{'print'} = 0;
$Config{'range'} = "yesterday";
$Config{'debug'} = 0;
$Config{'archives'} = 1;
$Config{'tmpdir'} = "/var/cache/logwatch";
$Config{'splithosts'} = 0;
$Config{'multiemail'} = 0;
$Config{'numeric'} = 0;
$Config{'pathtocat'} = "cat";
$Config{'pathtozcat'} = "zcat";
$Config{'pathtobzcat'} = "bzcat";
$Config{'output'} = "unformatted";
$Config{'encode'} = 0;
$Config{'html_wrap'} = 80;

if (-e "$ConfigDir/conf/html/header.html") {
   $Config{'html_header'} = "$ConfigDir/conf/html/header.html";
} elsif (-e "$BaseDir/dist.conf/html/header.html") {
   $Config{'html_header'} = "$BaseDir/dist.conf/html/header.html";
} else {
   $Config{'html_header'} = "$BaseDir/default.conf/html/header.html";
}

if (-e "$ConfigDir/conf/html/footer.html") {
   $Config{'html_footer'} = "$ConfigDir/conf/html/footer.html";
} elsif (-e "$BaseDir/dist.conf/html/footer.html") {
   $Config{'html_footer'} = "$BaseDir/dist.conf/html/footer.html";
} else {
   $Config{'html_footer'} = "$BaseDir/default.conf/html/footer.html";
}

# Logwatch now does some basic searching for logs
# So if the log file is not in the log path it will check /var/adm
# and then /var/log -mgt
$Config{'logdir'} = "/var/log";

#Added to create switches for different os options -mgt
#Changed to POSIX to remove calls to uname and hostname
my ($OSname, $hostname, $release, $version, $machine) = POSIX::uname();
$Config{'hostname'} = "$hostname";

#############################################################################

sub Usage () {
   # Show usage for this program
   print "\nUsage: $0 [--detail <level>] [--logfile <name>]\n" . 
      "   [--print] [--mailto <addr>] [--archives] [--range <range>] [--debug <level>]\n" .
      "   [--save <filename>] [--help] [--version] [--service <name>]\n" .
      "   [--numeric] [--output <output_type>]\n" .
      "   [--splithosts] [--multiemail]\n\n";
   print "--detail <level>: Report Detail Level - High, Med, Low or any #.\n";
   print "--logfile <name>: *Name of a logfile definition to report on.\n";
   print "--logdir <name>: Name of default directory where logs are stored.\n";
   print "--service <name>: *Name of a service definition to report on.\n";
   print "--print: Display report to stdout.\n";
   print "--mailto <addr>: Mail report to <addr>.\n";
   print "--archives: Use archived log files too.\n";
   print "--save <filename>: Save to <filename>.\n";
   print "--range <range>: Date range: Yesterday, Today, All, Help\n";
   print "                             where help will describe additional options\n";
   print "--numeric: Display addresses numerically rather than symbolically and numerically\n";
   print "           (saves  a  nameserver address-to-name lookup).\n";
   print "--debug <level>: Debug Level - High, Med, Low or any #.\n";
# hostname needs to be cleaned up and explained
#   print "--hostname <host>: 
   print "--splithosts: Create a report for each host in syslog.\n";
   print "--multiemail: Send each host report in a separate email.  Ignored if \n";
   print "              not using --splithosts.\n";
   print "--output <output type>: Report Format - mail, html or unformatted#.\n";
   print "--encode: Use base64 encoding on output mail.\n";
   print "--version: Displays current version.\n";
   print "--help: This message.\n";
   print "* = Switch can be specified multiple times...\n\n";
   exit (99);
}

my %wordsToInts = (yes  => 1,  no     => 0,
                   true => 1,  false  => 0,
                   on   => 1,  off    => 0,
                   high => 10,
                   med  => 5,  medium => 5,
                   low  => 0);

sub getInt {
   my $word = shift;
   my $tmpWord = lc $word;
   $tmpWord =~ s/\W//g;
   return $wordsToInts{$tmpWord} if (defined $wordsToInts{$tmpWord});
   unless ($word =~ s/^"(.*)"$/$1/) {
      return lc $word;
   }
   return $word;
}
              
sub CleanVars {
   foreach (keys %Config) {
      $Config{$_} = getInt($Config{$_});
   }
}

sub PrintStdArray (@) {
   my @ThisArray = @_;
   my $i;
   for ($i=0;$i<=$#ThisArray;$i++) {
      print "[" . $i . "] = " . $ThisArray[$i] . "\n";
   }
}

sub PrintConfig () {
   # for debugging, print out config...
   foreach (keys %Config) {
      print $_ . ' -> ' . $Config{$_} . "\n";
   }
   print "Service List:\n";
   PrintStdArray @ServiceList;
   print "\n";
   print "LogFile List:\n";
   PrintStdArray @LogFileList;
   print "\n\n";
}

# for debugging...
sub PrintServiceData () {
   my ($ThisKey1,$ThisKey2,$i);
   foreach $ThisKey1 (keys %ServiceData) {
      print "\nService Name: " . $ThisKey1 . "\n";
      foreach $ThisKey2 (keys %{$ServiceData{$ThisKey1}}) {
         next unless ($ThisKey2 =~ /^\d+-/);
         print "   $ThisKey2 = $ServiceData{$ThisKey1}{$ThisKey2}\n";
      }
      for ($i=0;$i<=$#{$ServiceData{$ThisKey1}{'logfiles'}};$i++) {
         print "   Logfile = " . $ServiceData{$ThisKey1}{'logfiles'}[$i] . "\n";
      }
   }
}

# for debugging...
sub PrintLogFileData () {
   my ($ThisKey1,$ThisKey2,$i);
   foreach $ThisKey1 (keys %LogFileData) {
      print "\nLogfile Name: " . $ThisKey1 . "\n";
      foreach $ThisKey2 (keys %{$LogFileData{$ThisKey1}}) {
         next unless ($ThisKey2 =~ /^\d+-/);
         print "   $ThisKey2 = $LogFileData{$ThisKey1}{$ThisKey2}\n";
      }
      for ($i=0;$i<=$#{$LogFileData{$ThisKey1}{'logfiles'}};$i++) {
         print "   Logfile = " . $LogFileData{$ThisKey1}{'logfiles'}[$i] . "\n";
      }
      for ($i=0;$i<=$#{$LogFileData{$ThisKey1}{'archives'}};$i++) {
         print "   Archive = " . $LogFileData{$ThisKey1}{'archives'}[$i] . "\n";
      }
   }
}

sub ReadConfigFile {
   my $FileName = $_[0];
   my $Prefix = $_[1];

   if ( ! -f $FileName ) {
      return(0);
   }

   if ($Config{'debug'} > 5) {
      print "ReadConfigFile: Opening " . $FileName . "\n";
   }
   open (READCONFFILE, $FileName) or die "Cannot open file $FileName: $!\n";
   my $line;
   while ($line = <READCONFFILE>) {
      if ($Config{'debug'} > 9) {
         print "ReadConfigFile: Read Line: " . $line;
      }
      $line =~ s/\#.*\\\s*$/\\/;
      $line =~ s/\#.*$//;
      next if ($line =~ /^\s*$/);

      if ($Prefix) {
         next if ($line !~ m/\Q$Prefix:\E/);
         $line =~ s/\Q$Prefix:\E//;
      }

      if ($line =~ s/\\\s*$//) {
	  $line .= <READCONFFILE>;
          redo unless eof(READCONFFILE);
      }

      my ($name, $value) = split /=/, $line, 2;
      $name =~ s/^\s+//; $name =~ s/\s+$//;
      if ($value) { $value =~ s/^\s+//; $value =~ s/\s+$//; }
      else { $value = ''; }

      push @ReadConfigNames, lc $name;
      push @ReadConfigValues, getInt $value;
      if ($Config{'debug'} > 7) {
         print "ReadConfigFile: Name=" . $name . ", Value=" . $value . "\n";
      }
   }
   close READCONFFILE;
}

#############################################################################

# Load main config file...
if ($Config{'debug'} > 8) {
   print "\nDefault Config:\n";
   PrintConfig();
}

CleanVars();

my $OldMailTo = $Config{'mailto'};
my $OldPrint  = $Config{'print'};

# For each of the configuration sets (logwatch.conf here, and
# logfiles,and services later), we do the following:
#  1. read the different configuration files
#  2. for each parameter, if it is cummulative, check if
#     it the special case empty string
#  3. check to see if duplicate

@ReadConfigNames = ();
@ReadConfigValues = ();

ReadConfigFile ("$BaseDir/default.conf/logwatch.conf", "");
ReadConfigFile ("$BaseDir/dist.conf/logwatch.conf", "");
ReadConfigFile ("$ConfigDir/conf/logwatch.conf", "");
ReadConfigFile ("$ConfigDir/conf/override.conf", "logwatch");


for (my $i = 0; $i <= $#ReadConfigNames; $i++) {
   if ($ReadConfigNames[$i] eq "logfile") {
      if ($ReadConfigValues[$i] eq "") {
	  @LogFileList = ();
      } elsif (! grep(/^$ReadConfigValues[$i]$/, @LogFileList)) {
         push @LogFileList, $ReadConfigValues[$i];
      }
   } elsif ($ReadConfigNames[$i] eq "service") {
      if ($ReadConfigValues[$i] eq "") {
	  @ServiceList = ();
      } elsif (! grep(/^$ReadConfigValues[$i]$/, @ServiceList)) {
         push @ServiceList, $ReadConfigValues[$i];
      }
   } else {
      $Config{$ReadConfigNames[$i]} = $ReadConfigValues[$i];
   }
}

CleanVars();

if ($OldMailTo ne $Config{'mailto'}) {
   $Config{'print'} = 0;
} elsif ($OldPrint ne $Config{'print'}) {
   $Config{'mailto'} = "";
}

if ($Config{'debug'} > 8) {
   print "\nConfig After Config File:\n";
   PrintConfig();
}

# Options time...

my @TempLogFileList = ();
my @TempServiceList = ();
my $Help = 0;
my $ShowVersion = 0;

$OldMailTo = $Config{'mailto'};
$OldPrint  = $Config{'print'};

GetOptions ( "d|detail=s"   => \$Config{'detail'},
             "l|logfile=s@" => \@TempLogFileList,
             "logdir=s"     => \$Config{'logdir'},
             "s|service=s@" => \@TempServiceList,
             "p|print"      => \$Config{'print'},
             "m|mailto=s"   => \$Config{'mailto'},
             "save=s"       => \$Config{'save'},
             "a|archives"   => \$Config{'archives'},
             "debug=s"      => \$Config{'debug'},
             "r|range=s"    => \$Config{'range'},
             "n|numeric"    => \$Config{'numeric'},
             "h|help"       => \$Help,
             "v|version"    => \$ShowVersion,
             "hostname=s"   => \$Config{'hostname'},
             "splithosts"   => \$Config{'splithosts'},
             "multiemail"   => \$Config{'multiemail'},
             "o|output=s"   => \$Config{'output'},
             "encode"       => \$Config{'encode'},
             "html_wrap=s"  => \$Config{'html_wrap'}
           ) or Usage();

$Help and Usage();

if ($Config{'range'} =~ /help/i) {
    RangeHelpDM();
    exit(0);
}

if ($ShowVersion) {
   print "Logwatch $Version (released $VDate)\n";
   exit 0;
}

CleanVars();


my $outtype_mail=0;
my $outtype_html=0;
my $outtype_unformatted=0;
my $index_par=0;
my @format = (250);
my %out_body;

if ( $Config{'output'} eq 'mail' ) {
	    $outtype_mail = 1;
	} elsif ( ($Config{'output'} eq 'html') || ($Config{'output'} eq 'html-embed') ) {
      #kept html-embed for backwarks compatibility -mgt
	    $outtype_html = 1;
	} elsif ( $Config{'output'} eq 'unformatted' ) {
	    $outtype_unformatted = 1;
	} else {
	    print STDERR "$0: unknown output-format: $Config{'output'}\n\n";
	}


my @reports = ();

my $out_head ='';
my $out_mime ='';
my $out_reference ='';
my $out_foot ='';

#Eval wrapper for MIME::Base64. Perl 5.6.1 does not include it.
#So Solaris 9 will break with out this. -mgt
if ( $Config{'encode'} == 1 ) {
   eval "require MIME::Base64";
   if ($@) {
      print STDERR "No MIME::Base64 installed can not use --encode\n";
    } else {
      import MIME::Base64;
   }
}

if (($Config{'save'} ne "") && (-e "$Config{'save'}") ) {
#Reset save file now
   unlink "$Config{'save'}";
}

if ($OldMailTo ne $Config{'mailto'}) {
   $Config{'print'} = 0;
} elsif ($OldPrint ne $Config{'print'}) {
   $Config{'mailto'} = "";
}

if ($Config{'debug'} > 8) {
   print "\nCommand Line Parameters:\n   Log File List:\n";
   PrintStdArray @TempLogFileList;
   print "\n   Service List:\n";
   PrintStdArray @TempServiceList;
   print "\nConfig After Command Line Parsing:\n";
   PrintConfig();
}

if ($#TempLogFileList > -1) {
   @LogFileList = @TempLogFileList;
   for (my $i = 0; $i <= $#LogFileList; $i++) {
      $LogFileList[$i] = lc($LogFileList[$i]);
   }
   @ServiceList = ();
}

if ($#TempServiceList > -1) {
   @ServiceList = @TempServiceList;
   for (my $i = 0; $i <= $#ServiceList; $i++) {
      $ServiceList[$i] = lc($ServiceList[$i]);
   }
}

if ( ($#ServiceList == -1) and ($#LogFileList == -1) ) {
   push @ServiceList, 'all';
}

if ($Config{'debug'} > 5) {
   print "\nConfig After Everything:\n";
   PrintConfig();
}

#############################################################################

# Find out what services are defined...
my @TempAllServices = ();
my @services = ();
my (@CmdList, @CmdArgList, @Separators, $ThisFile, $count);


foreach my $ServicesDir ("$BaseDir/default.conf", "$BaseDir/dist.conf", "$ConfigDir/conf") {
   if (-d "$ServicesDir/services") {
      opendir(SERVICESDIR, "$ServicesDir/services") or
         die "$ServicesDir $!";
      while (defined($ThisFile = readdir(SERVICESDIR))) {
	 if ((-f "$ServicesDir/services/$ThisFile") && (!grep (/^$ThisFile$/, @services)) && ($ThisFile =~ /\.conf$/)) {
	     push @services, $ThisFile;
         }
      }
      closedir SERVICESDIR;
   }
}

foreach my $f (@services) {
   my $ThisService = lc $f;
   $ThisService =~ s/\.conf$//;
   push @TempAllServices, $ThisService;

   # @Separators tells us where each of the config files start, and
   # is used only for the commands (entries that start with '*')
   @ReadConfigNames = ();
   @ReadConfigValues = ();
   @Separators = ();
   push (@Separators, scalar(@ReadConfigNames));
   ReadConfigFile("$BaseDir/default.conf/services/$f", "");
   push (@Separators, scalar(@ReadConfigNames));
   ReadConfigFile("$BaseDir/dist.conf/services/$f", "");
   push (@Separators, scalar(@ReadConfigNames));
   ReadConfigFile("$ConfigDir/conf/services/$f","");
   push (@Separators, scalar(@ReadConfigNames));
   ReadConfigFile("$ConfigDir/conf/override.conf", "services/$ThisService");

   @CmdList = ();
   @CmdArgList = ();

   # set the default for DisplayOrder (0.5), which should be a fraction of any precision between 0 and 1
   $ServiceData{$ThisService}{'displayorder'} = 0.5;

   for (my $i = 0; $i <= $#ReadConfigNames; $i++) {
      if (grep(/^$i$/, @Separators)) {
         $count = 0;
      }

      if ($ReadConfigNames[$i] eq 'logfile') {
         if ($ReadConfigValues[$i] eq "") {
	         @{$ServiceData{$ThisService}{'logfiles'}} = ();
         } elsif (! grep(/^$ReadConfigValues[$i]$/, @{$ServiceData{$ThisService}{'logfiles'}})) {
            push @{$ServiceData{$ThisService}{'logfiles'}}, $ReadConfigValues[$i];
	      }
      } elsif ($ReadConfigNames[$i] =~ /^\*/) {
	      if ($count == 0) {
	         @CmdList = ();
	         @CmdArgList = ();
	      }
         $count++;
         push (@CmdList, $ReadConfigNames[$i]);
         push (@CmdArgList, $ReadConfigValues[$i]);
      } else {
         $ServiceData{$ThisService}{$ReadConfigNames[$i]} = $ReadConfigValues[$i];
      }
   }
   for my $i (0..$#CmdList) {
       $ServiceData{$ThisService}{+sprintf("%03d-%s", $i, $CmdList[$i])} = $CmdArgList[$i];
   }
}
my @AllServices = sort @TempAllServices;

# Find out what logfiles are defined...
my @logfiles = ();
foreach my $LogfilesDir ("$BaseDir/default.conf", "$BaseDir/dist.conf", "$ConfigDir/conf") {
   if (-d "$LogfilesDir/logfiles") {
      opendir(LOGFILEDIR, "$LogfilesDir/logfiles") or
         die "$LogfilesDir $!";
      while (defined($ThisFile = readdir(LOGFILEDIR))) {
	 if ((-f "$LogfilesDir/logfiles/$ThisFile") && (!grep (/^$ThisFile$/, @logfiles))) {
	     push @logfiles, $ThisFile;
         }
      }
      closedir LOGFILEDIR;
   }
}

for $ThisFile (@logfiles) {
      my $ThisLogFile = $ThisFile;
      if ($ThisLogFile =~ s/\.conf$//i) {
         push @AllLogFiles, $ThisLogFile;
         @ReadConfigNames = ();
         @ReadConfigValues = ();
         @Separators = ();
         push (@Separators, scalar(@ReadConfigNames));
         ReadConfigFile("$BaseDir/default.conf/logfiles/$ThisFile", "");
         push (@Separators, scalar(@ReadConfigNames));
         ReadConfigFile("$BaseDir/dist.conf/logfiles/$ThisFile", "");
         push (@Separators, scalar(@ReadConfigNames));
         ReadConfigFile("$ConfigDir/conf/logfiles/$ThisFile", "");
         push (@Separators, scalar(@ReadConfigNames));
         ReadConfigFile("$ConfigDir/conf/override.conf", "logfiles/$ThisLogFile");

         @CmdList = ();
         @CmdArgList = ();

         @{$LogFileData{$ThisLogFile}{'logfiles'}} = ();
         @{$LogFileData{$ThisLogFile}{'archives'}} = ();
         for (my $i = 0; $i <= $#ReadConfigNames; $i++) {
            if (grep(/^$i$/, @Separators)) {
               $count = 0;
            }
            my @TempLogFileList;
            if ($ReadConfigNames[$i] eq "logfile") {
               #Lets try and find the logs -mgt
               if ($ReadConfigValues[$i] eq "") {
                  @{$LogFileData{$ThisLogFile}{'logfiles'}} = ();
               } else {
                  if ($ReadConfigValues[$i] !~ m=^/=) {
                     foreach my $dir ("$Config{'logdir'}/", "/var/adm/", "/var/log/", "") {
                        # We glob to obtain filenames.  We reverse in case
                        # we use the decimal suffix (.0, .1, etc.) in filenames
                        @TempLogFileList = reverse(glob($dir . $ReadConfigValues[$i]));
                        # And we check for existence once again, since glob
                        # may return the search pattern if no files found.
                        last if (@TempLogFileList && (-e $TempLogFileList[0]));
                     }
                  } else {
                     @TempLogFileList = reverse(glob($ReadConfigValues[$i]));
                  }

                  # We attempt to remove duplicates.
                  # Same applies to archives, in the next block.
                  foreach my $TempLogFileName (@TempLogFileList) {
                     if (grep(/^\Q$TempLogFileName\E$/,
                           @{$LogFileData{$ThisLogFile}{'logfiles'}})) {
                        if ($Config{'debug'} > 2) {
                           print "Removing duplicate LogFile file $TempLogFileName from $ThisFile configuration.\n";
                        }
                     } else {
                        if (-e $TempLogFileName) {
                           push @{$LogFileData{$ThisLogFile}{'logfiles'}},
                              $TempLogFileName;
                        }
                     }
                  }
               }
            } elsif (($ReadConfigNames[$i] eq "archive") && ( $Config{'archives'} == 1)) {
               if ($ReadConfigValues[$i] eq "") {
                  @{$LogFileData{$ThisLogFile}{'archives'}} = ();
               } else {
                  if ($ReadConfigValues[$i] !~ m=^/=) {
                     foreach my $dir ("$Config{'logdir'}/", "/var/adm/", "/var/log/", "") {
                        # We glob to obtain filenames.  We reverse in case
                        # we use the decimal suffix (.0, .1, etc.) in filenames
                        @TempLogFileList = reverse(glob($dir . $ReadConfigValues[$i]));
                        # And we check for existence once again, since glob
                        # may return the search pattern if no files found.
                        last if (@TempLogFileList && (-e $TempLogFileList[0]));
                     }
                  } else {
                     @TempLogFileList = reverse(glob($ReadConfigValues[$i]));
                  }

                  # We attempt to remove duplicates.  This time we also check
                  # against the LogFile declarations.
                  foreach my $TempLogFileName (@TempLogFileList) {
                     if (grep(/^\Q$TempLogFileName\E$/,
                           @{$LogFileData{$ThisLogFile}{'archives'}}) ||
                         grep(/^\Q$TempLogFileName\E$/,
                           @{$LogFileData{$ThisLogFile}{'logfiles'}}) ) {
                        if ($Config{'debug'} > 2) {
                           print "Removing duplicate Archive file $TempLogFileName from $ThisFile configuration.\n";
                        }
                     } else {
                        if (-e $TempLogFileName) {
                           push @{$LogFileData{$ThisLogFile}{'archives'}},
                              $TempLogFileName;
                           }
                     }
                  }
               }

            } elsif ($ReadConfigNames[$i] =~ /^\*/) {
               if ($count == 0) {
                  @CmdList = ();
                  @CmdArgList = ();
               }
               $count++;
               push (@CmdList, $ReadConfigNames[$i]);
               push (@CmdArgList, $ReadConfigValues[$i]);
            } else {
               $LogFileData{$ThisLogFile}{$ReadConfigNames[$i]} = $ReadConfigValues[$i];
            }
            for my $i (0..$#CmdList) {
                $LogFileData{$ThisLogFile}{+sprintf("%03d-%s", $i, $CmdList[$i])} = $CmdArgList[$i];
            }
         }
      }
}

# Find out what shared functions are defined...
opendir(SHAREDDIR, "$BaseDir/scripts/shared") or die "$BaseDir/scripts/shared/, $!\n";
while (defined($ThisFile = readdir(SHAREDDIR))) {
   unless (-d "$BaseDir/scripts/shared/$ThisFile") {
      push @AllShared, lc($ThisFile);
   }
}
closedir(SHAREDDIR);

if ($Config{'debug'} > 5) {
   print "\nAll Services:\n";
   PrintStdArray @AllServices;
   print "\nAll Log Files:\n";
   PrintStdArray @AllLogFiles;
   print "\nAll Shared:\n";
   PrintStdArray @AllShared;
}

#############################################################################

# Time to expand @ServiceList, using @LogFileList if defined...

if ((scalar @ServiceList > 0) && (grep /^all$/i, @ServiceList)) {
    # This means we are doing *all* services ... but excluding some
    my %tmphash;
    foreach my $item (@AllServices) {
      $tmphash{lc $item} = "";
    }
    foreach my $service (@ServiceList) {
      next if $service =~ /^all$/i;
      if ($service =~ /^\-(.+)$/) {
          my $offservice = lc $1;
          if (! grep (/^$offservice$/, @AllServices)) {
             die "Nonexistent service to disable: $offservice\n";
          }
          if (exists $tmphash{$offservice}) {
             delete $tmphash{$offservice};
          }
          
      } else {
          die "Wrong configuration entry for \"Service\", if \"All\" selected, only \"-\" items are allowed\n";
      }
    }
    @ServiceList = ();
    foreach my $keys (keys %tmphash) {
      push @ServiceList, $keys;
    }
    @LogFileList = ();
} else {
   my $ThisOne;
   while (defined($ThisOne = pop @LogFileList)) {
      unless ($LogFileData{$ThisOne}) {
         die "Logwatch is not configured to use logfile: $ThisOne\n";
      }
      foreach my $ThisService (keys %ServiceData) {
         for (my $i = 0; $i <= $#{$ServiceData{$ThisService}{'logfiles'}}; $i++) {
            if ( $ServiceData{$ThisService}{'logfiles'}[$i] eq $ThisOne ) {
               push @ServiceList,$ThisService;
            }
         }
      }
   }
   @TempServiceList = sort @ServiceList;
   @ServiceList = ();
   my $LastOne = "";
   while (defined($ThisOne = pop @TempServiceList)) {
      unless ( ($ThisOne eq $LastOne) or ($ThisOne eq 'all') or ($ThisOne =~ /^-/)) {
         unless ($ServiceData{$ThisOne}) {
            die "Logwatch does not know how to process service: $ThisOne\n";
         }
         push @ServiceList, $ThisOne;
      }
      $LastOne = $ThisOne;
   }
}

# Now lets fill up @LogFileList again...
foreach my $ServiceName (@ServiceList) {
   foreach my $LogName ( @{$ServiceData{$ServiceName}{'logfiles'} } ) {
      unless ( grep m/^$LogName$/, @LogFileList ) { 
         push @LogFileList, $LogName;
      }
   }
}

if ($Config{'debug'} > 7) {
   print "\n\nAll Service Data:\n";
   PrintServiceData;
   print "\nServices that will be processed:\n";
   PrintStdArray @ServiceList;
   print "\n\n";
   print "\n\nAll LogFile Data:\n";
   PrintLogFileData;
   print "\nLogFiles that will be processed:\n";
   PrintStdArray @LogFileList;
   print "\n\n";
}

#############################################################################

# check for existence of previous logwatch directories

opendir(TMPDIR, $Config{'tmpdir'}) or die "$Config{'tmpdir'} $!";
my @old_dirs = grep { /^logwatch\.\w{8}$/ && -d "$Config{'tmpdir'}/$_" }
   readdir(TMPDIR);
if (@old_dirs) {
   print "You have old files in your logwatch tmpdir ($Config{'tmpdir'}):\n\t";
   print join("\n\t", @old_dirs);
   print "\nThe directories listed above were most likely created by a\n";
   print "logwatch run that failed to complete successfully.  If so, you\n";
   print "may delete these directories.\n\n";
}
closedir(TMPDIR);

if (!-w $Config{'tmpdir'}) {
   my $err_str = "You do not have permission to create a temporary directory";
   $err_str .= " under $Config{'tmpdir'}.";
   if ($> !=0) {
      $err_str .= "  You are not running as superuser.";
   }
   $err_str .= "\n";
   die $err_str;
}

#Set very strict permissions because we deal with security logs
umask 0177;
#Making temp dir with File::Temp  -mgt
my $cleanup = 0;
if ($Config{'debug'} < 100) {
   $cleanup = 1;
}

my $TempDir = tempdir( 'logwatch.XXXXXXXX', DIR => $Config{tmpdir},
      CLEANUP => $cleanup );

if ($Config{'debug'}>7) {
      print "\nMade Temp Dir: " . $TempDir . " with tempdir\n";
}

unless ($TempDir =~ m=/$=) {
    $TempDir .= "/";
}
   
#############################################################################

# Set up the environment...

$ENV{'LOGWATCH_DATE_RANGE'} = $Config{'range'};
$ENV{'LOGWATCH_GLOBAL_DETAIL'} = $Config{'detail'};
$ENV{'LOGWATCH_OUTPUT_TYPE'} = $Config{'output'};
$ENV{'LOGWATCH_DEBUG'} = $Config{'debug'};
$ENV{'LOGWATCH_TEMP_DIR'} = $TempDir;
$ENV{'LOGWATCH_NUMERIC'} = $Config{'numeric'};
$ENV{'HOSTNAME'} = $Config{'hostname'};
$ENV{'OSname'} = $OSname;

if ($Config{'hostlimit'}) {
   $ENV{'LOGWATCH_ONLY_HOSTNAME'} = $Config{'hostname'};
#   $ENV{'LOGWATCH_ONLY_HOSTNAME'} =~ s/\..*//;
}
if ($Config{'debug'}>4) {
   foreach ('LOGWATCH_DATE_RANGE', 'LOGWATCH_GLOBAL_DETAIL', 'LOGWATCH_OUTPUT_TYPE', 
            'LOGWATCH_TEMP_DIR', 'LOGWATCH_DEBUG', 'LOGWATCH_ONLY_HOSTNAME') {
      if ($ENV{$_}) {
         print "export $_='$ENV{$_}'\n";
      }
   }
}

my $LibDir = "$BaseDir/lib";
if ($ENV{PERL5LIB}) {
    # User dirs should be able to override this setting
    $ENV{PERL5LIB} = "$ENV{PERL5LIB}:$LibDir";
} else {
    $ENV{PERL5LIB} = $LibDir;
}

#############################################################################

unless ($Config{'logdir'} =~ m=/$=) {
   $Config{'logdir'} .= "/";
}

# Okay, now it is time to do pre-processing on all the logfiles...

my @EnvList = ();
my $LogFile;
foreach $LogFile (@LogFileList) {
   next if ($LogFile eq 'none');
	if (!defined($LogFileData{$LogFile}{'logfiles'})) {
		print "*** Error: There is no logfile defined. Do you have a $ConfigDir/conf/logfiles/" . $LogFile . ".conf file ?\n";
		next;
	}

   @FileList = $TempDir . $LogFile . "-archive";
   push @FileList, @{$LogFileData{$LogFile}{'logfiles'}};
   my $DestFile =  $TempDir . $LogFile . "-archive";
   my $Archive;
   foreach $Archive (@{$LogFileData{$LogFile}{'archives'}}) {
      my $CheckTime;
      # We need to find out what's the earliest log we need
      my @time_t = TimeBuild();
      if ($Config{'range'} eq 'all') {
         if ($Config{'archives'} == 0) {
            # range is 'all', but we don't get archive files
   	      $CheckTime = time;
         } else {
            # range is 'all', and we get all archive files
   	      $CheckTime = 0;
         }
      } elsif ($time_t[0]) {
         # range is something else, and we need to get one
       # day ahead. A day has 86400 seconds.  (We double
       # that to deal with different timezones.)
       $CheckTime = $time_t[0] - 86400*2;
      } else {
         # range is wrong
         $CheckTime = time;
      }

      my @FileStat = stat($Archive);
      if ($CheckTime <= ($FileStat[9])) {
         if (($Archive =~ m/gz$/) && (-f "$Archive")) {
         #These system calls are not secure but we are getting closer
         #What needs to go is all the pipes and instead we need a command loop
         #For each filter to apply -mgt
            my $arguments = "$Archive >> $DestFile";
            system("$Config{'pathtozcat'} $arguments") == 0
               or die "system $Config{'pathtozcat'} failed: $?" 
         } elsif (($Archive =~ m/bz2$/) && (-f "$Archive")) {
         #These system calls are not secure but we are getting closer
         #What needs to go is all the pipes and instead we need a command loop
         #For each filter to apply -mgt
            my $arguments = "$Archive 2>/dev/null >> $DestFile";
            system("$Config{'pathtobzcat'} $arguments") == 0
               or die "system $Config{'pathtobzcat'} failed: $?" 
         } elsif (-f "$Archive") {
            my $arguments = "$Archive  >> $DestFile";
            system("$Config{'pathtocat'} $arguments") == 0
               or die "system $Config{'pathtocat'} failed: $?" 
         } #End if/elsif existence
      } #End if $CheckTime

   } #End Archive
   my $FileText = "";

   foreach my $ThisFile (@FileList) {
      #Existence check for files -mgt
      next unless (-f $ThisFile);
      if (! -r $ThisFile) {
         print "File $ThisFile is not readable.  Check permissions.";
         if ($> != 0) {
            print "  You are not running as superuser.";
            }
         print "\n";
         next;
      }
      $FileText .= ($ThisFile . " ");
   } #End foreach ThisFile

   # remove the ENV entries set by previous service
   foreach my $Parm (@EnvList) {
      delete $ENV{$Parm};
   }
   @EnvList = ();

   my $FilterText = " ";
   foreach (sort keys %{$LogFileData{$LogFile}}) {
      my $cmd = $_;
      if ($cmd =~ s/^\d+-\*//) {
         if (-f "$ConfigDir/scripts/shared/$cmd") {
            $FilterText .= ("| $PerlVersion $ConfigDir/scripts/shared/$cmd '$LogFileData{$LogFile}{$_}'" );
         } elsif (-f "$BaseDir/scripts/shared/$cmd") {
            $FilterText .= ("| $PerlVersion $BaseDir/scripts/shared/$cmd '$LogFileData{$LogFile}{$_}'" );
         } else {
	     die "Cannot find shared script $cmd\n";
         }
      } elsif ($cmd =~ s/^\$//) {
         push @EnvList, $cmd;
         $ENV{$cmd} = $LogFileData{$LogFile}{$_};
         if ($Config{'debug'}>4) {
            print "export $cmd='$LogFileData{$LogFile}{$_}'\n";
         }
      }
   }
   if (opendir (LOGDIR, "$ConfigDir/scripts/logfiles/" . $LogFile)) {
      foreach (sort readdir(LOGDIR)) {
         unless ( -d "$ConfigDir/scripts/logfiles/$LogFile/$_") {
            $FilterText .= ("| $PerlVersion $ConfigDir/scripts/logfiles/$LogFile/$_");
         }
      }
      closedir (LOGDIR);
   }
   if (opendir (LOGDIR, "$BaseDir/scripts/logfiles/" . $LogFile)) {
      foreach (sort readdir(LOGDIR)) {
         unless (( -d "$BaseDir/scripts/logfiles/$LogFile/$_") or
                 # if in ConfigDir, then the ConfigDir version is used
                 ( -f "$ConfigDir/scripts/logfiles/$LogFile/$_")) {
            $FilterText .= ("| $PerlVersion $BaseDir/scripts/logfiles/$LogFile/$_");
         }
      }
      closedir (LOGDIR);
   }

   #Instead of trying to cat non-existent logs we test for it above -mgt
   if ($FileText) {
      my $Command = $FileText . $FilterText . ">" . $TempDir . $LogFile;
      if ($Config{'debug'}>4) {
         print "\nPreprocessing LogFile: " . $LogFile . "\n" . $Command . "\n";
      }
      if ($LogFile !~ /^[-_\w\d]+$/) {
         print STDERR "Unexpected filename: [[$LogFile]]. Not used\n"
      } else {
      #These system calls are not secure but we are getting closer
      #What needs to go is all the pipes and instead we need a command loop
      #For each filter to apply -mgt
         system("$Config{'pathtocat'} $Command") == 0
            or die "system $Config{'pathtocat'} $Command failed: $?" 
      }
   }
}

#populate the host lists if we're splitting hosts
my @hosts;
if ($Config{'splithosts'} eq 1) {
   my $newlogfile;
   my @logarray;
   opendir (LOGDIR,$TempDir) || die "Cannot open dir";
   @logarray = readdir(LOGDIR);
   closedir (LOGDIR);
   my $ecpcmd = ("| $PerlVersion $BaseDir/scripts/shared/hostlist");
   foreach $newlogfile (@logarray) {
     my $eeefile = ("$TempDir" . "$newlogfile");
     if ((!(-d $eeefile)) && (!($eeefile =~ m/-archive/))) {
         system("$Config{'pathtocat'} $eeefile $ecpcmd") == 0
            or die "system $Config{'pathtocat'} $eeefile $ecpcmd failed: $?" 
     }
   }
   #read in the final host list
   open (HOSTFILE,"$TempDir/hostfile") || die $!;
   @hosts = <HOSTFILE>;
   close (HOSTFILE);
   chomp @hosts;
   #@hosts = sort(@hosts);
}

#############################################################################

my $report_finish = "\n ###################### Logwatch End ######################### \n\n";
my $printing = '';
my $emailopen = '';

sub initprint {
   return if $printing;

   my $OStitle;
   $OStitle = $OSname;
   $OStitle = "Solaris" if ($OSname eq "SunOS" && $release >= 2);

   if ($Config{'print'} eq 1) {
      *OUTFILE = *STDOUT;
   } elsif ($Config{'save'} ne "") {
      open(OUTFILE,">>" . $Config{'save'}) or die "Can't open output file: $Config{'save'} $!\n";
   } else {
      if (($Config{'multiemail'} eq 1) || ($emailopen eq "")) {
         #Use mailer = in logwatch.conf to set options. Default should be "sendmail -t"
         #In theory this should be able to handle many different mailers. I might need to add
         #some filter code on $Config{'mailer'} to make it more robust. -mgt
         open(OUTFILE,"|$Config{'mailer'}") or die "Can't execute $Config{'mailer'}: $!\n";
         print OUTFILE "To: $Config{'mailto'}\n";
         print OUTFILE "From: $Config{'mailfrom'}\n";
         print OUTFILE "Subject: Logwatch for $Config{'hostname'} (${OStitle})\n";
         #Add MIME
         $out_mime .= "MIME-Version: 1.0\n"; 
         if ( $Config{encode} == 1 ) {
            $out_mime .= "Content-transfer-encoding: base64\n";
         } else {
            $out_mime .= "Content-Transfer-Encoding: 7bit\n";
         }
         if ( $outtype_html ) {
            $out_mime .= "Content-Type: text/html; charset=\"iso-8859-1\"\n\n";
         } else {
            $out_mime .= "Content-Type: text/plain; charset=\"iso-8859-1\"\n\n";
         }

         if (($Config{'splithosts'} eq 1) && ($Config{'multiemail'} eq 0)) {
            print OUTFILE "Reporting on hosts: @hosts\n";
         }
         $emailopen = 'y';
      } #End if multiemail || emailopen 
   } #End if printing/save/else
   $printing = 'y';

   # simple parse of the dates
   my $simple_timematch = TimeFilter(" %Y-%b-%d %Hh %Mm %Ss ");
   my @simple_range = split(/\|/, $simple_timematch);
   if ($#simple_range > 1) {
       # delete all array entries, except first and last
       splice(@simple_range, 1, $#simple_range-1);
   }
   for (my $range_index=0; $range_index<$#simple_range+1; $range_index++) {
       $simple_range[$range_index] =~ s/\.\.[hms]//g;
       $simple_range[$range_index] =~ s/\.//g;
       $simple_range[$range_index] =~ tr/--//s;
       $simple_range[$range_index] =~ s/ -|- //;
       $simple_range[$range_index] =~ tr/ //s;
   }

   my $print_range = join("/",@simple_range);

   $index_par++;
   if ( $outtype_html ) {
      output( $index_par, "LOGWATCH Summary" . (($Config{'splithosts'} eq 1) ? ": $Config{'hostname'}" : ""), "start");
      output( $index_par, "\n <h2><font color=\"blue\"> Logwatch $Version ($VDate)</font></h2>\n", "header");
   }       else {
      output( $index_par, "\n ################### Logwatch $Version ($VDate) #################### \n", "line");
   }

   output( $index_par, "       Processing Initiated: " . localtime(time) . "\n", "line");
   output( $index_par, "       Date Range Processed: $Config{'range'}\n", "line");
   output( $index_par, "                             $print_range\n", "line") if ($Config{'range'} ne 'all');
   output( $index_par, "                             Period is " . GetPeriod() . ".\n", "line")
      if ($Config{'range'} ne 'all');
   output( $index_par, "     Detail Level of Output: $Config{'detail'}\n", "line");
   output( $index_par, "             Type of Output: $Config{'output'}\n", "line");
   output( $index_par, "          Logfiles for Host: $Config{'hostname'}\n", "line");

   if ( $outtype_html ) {
      output( $index_par, "\n", "stop");
   } else {
      output( $index_par, " ################################################################## \n", "line");
   }

}

sub parselogs {
   my $Service;

   #Load our ignore file
   my @IGNORE;
   if ( -e "$ConfigDir/conf/ignore.conf") {
      open( IGNORE, "$ConfigDir/conf/ignore.conf" )  or return undef;
      @IGNORE = grep {!/(^#|^\s+$)/} <IGNORE>;
      close IGNORE;
   }

   my @EnvList = ();

   # first sort alphabetically, and then based on DisplayOrder
   foreach $Service ( sort {$ServiceData{$a}{'displayorder'} <=>
                            $ServiceData{$b}{'displayorder'}     } (sort @ServiceList)) {

      my $Ignored = 0;
      $ENV{'PRINTING'} = $printing;
      if (defined $ServiceData{$Service}{'detail'}) {
	      $ENV{'LOGWATCH_DETAIL_LEVEL'} = $ServiceData{$Service}{'detail'};
      } else {
         $ENV{'LOGWATCH_DETAIL_LEVEL'} = $ENV{'LOGWATCH_GLOBAL_DETAIL'};
      }
      @FileList = @{$ServiceData{$Service}{'logfiles'}};
      my $FileText = "";
      foreach $ThisFile (@FileList) {
         if (-s $TempDir . $ThisFile) {
            $FileText .= ( $TempDir . $ThisFile . " ");
         }
      }

      # remove the ENV entries set by previous service
      foreach my $Parm (@EnvList) {
         delete $ENV{$Parm};
      }
      @EnvList = ();

      my $FilterText = " ";
      foreach (sort keys %{$ServiceData{$Service}}) {
         my $cmd = $_;
         if ($cmd =~ s/^\d+-\*//) {
            if (-f "$ConfigDir/scripts/shared/$cmd") {
               $FilterText .= ("$PerlVersion $ConfigDir/scripts/shared/$cmd '$ServiceData{$Service}{$_}' |" );
            } elsif (-f "$BaseDir/scripts/shared/$cmd") {
               $FilterText .= ("$PerlVersion $BaseDir/scripts/shared/$cmd '$ServiceData{$Service}{$_}' |" );
            } else {
               die "Cannot find shared script $cmd\n";
            }
         } elsif ($cmd =~ s/^\$//) {
            $ENV{$cmd} = $ServiceData{$Service}{$_};
            push @EnvList, $cmd;
            if ($Config{'debug'}>4) {
               print "export $cmd='$ServiceData{$Service}{$_}'\n";
            }
         }
      }
# ECP - insert the host stripping now
      my $HostStrip = " ";
      if ($Config{'splithosts'} eq 1) {
         $HostStrip .= ("$PerlVersion $BaseDir/scripts/shared/onlyhost");
      }
      my $ServiceExec = "$BaseDir/scripts/services/$Service";
      if (-f "$ConfigDir/scripts/services/$Service") {
         $ServiceExec = "$ConfigDir/scripts/services/$Service";
      } else {
         $ServiceExec = "$BaseDir/scripts/services/$Service";
      }

      if (-f $ServiceExec ) {
         #If shell= was set in service.conf we will use it
         if ($ServiceData{$Service}{shell}) {
            my $shelltest = $ServiceData{$Service}{shell};
            $shelltest =~ s/([\w\/]+).*/$1/;
            if (-e "$shelltest") {
               $FilterText .= "$ServiceData{$Service}{shell} $ServiceExec";
            } else {
               die "Can't use $ServiceData{$Service}{shell} for $ServiceExec";
            }
         } else {
            $FilterText .= "$PerlVersion $ServiceExec";
         } #End if shell
      }
      else {
         die "Can't open: " . $ServiceExec;
      }

      my $Command = '';
      if ($FileList[0] eq 'none') {
         $Command = " $FilterText 2>&1 "; 
      } elsif ($FileText) {
         if ($HostStrip ne " ") {
            $Command = " ( $Config{'pathtocat'} $FileText | $HostStrip | $FilterText) 2>&1 "; 
         } else {
            $Command = " ( $Config{'pathtocat'} $FileText | $FilterText) 2>&1 "; 
         }
      }
   
      if ($Command) {
         if ($Config{'debug'}>4) {
            print "\nProcessing Service: " . $Service . "\n" . $Command . "\n";
         }
         open (TESTFILE,$Command . " |");
         my $ThisLine;
         my $has_output = 0;
         LINE: while (defined ($ThisLine = <TESTFILE>)) {
            next LINE if ((not $printing) and $ThisLine =~ /^\s*$/);
            IGNORE: for my $ignore_filter (@IGNORE) {
               chomp $ignore_filter;
               if ($ThisLine =~ m/$ignore_filter/) {
                  $Ignored++;
                  next LINE;
                  }
            }
            initprint();
            if (($has_output == 0) and ($ServiceData{$Service}{'title'})) {
               $index_par++;
               output($index_par, $ServiceData{$Service}{'title'}, "start" );
               my $BeginVar;
               if ($ENV{'LOGWATCH_GLOBAL_DETAIL'} == $ENV{'LOGWATCH_DETAIL_LEVEL'}) {
                  $BeginVar = "Begin";
               } else {
                  $BeginVar = "Begin (detail=" . $ENV{'LOGWATCH_DETAIL_LEVEL'} . ")";
               }
               if ( $outtype_html ) {
               #BODY <!-- SERVICE START -->
                   output( $index_par, "\n <h3><font color=\"blue\">$ServiceData{$Service}{'title'} $BeginVar </font></h3>\n", "header");
               } else {
                   output( $index_par, "\n --------------------- $ServiceData{$Service}{'title'} $BeginVar ------------------------ \n\n", "line");
               }
               $has_output = 1;
            }
            output( $index_par, $ThisLine, "line");
         }
         close (TESTFILE);

         if ($has_output and $ServiceData{$Service}{'title'}) {
            if ( $outtype_html ) {
                if ($Ignored > 0) {  output( $index_par, "\n $Ignored Ignored Lines\n", "header"); };
                output( $index_par,  "\n <h3><font color=\"blue\">$ServiceData{$Service}{'title'} End </font></h3>\n", "header");
            } else {
                if ($Ignored > 0) { output( $index_par, "\n $Ignored Ignored Lines\n", "line"); };
                output( $index_par,  "\n ---------------------- $ServiceData{$Service}{'title'} End ------------------------- \n\n", "line");
            }
            output( $index_par, "\n", "stop");
         }
      }
   }

   #HTML should be external to logwatch.pl -mgt 
   #These are steps only needed for HTML output
   if ( $outtype_html ) {
      #HEADER 
      #Setup temp Variables to swap
      my %HTML_var;
      $HTML_var{Version} = "$Version";
      $HTML_var{VDate} = "$VDate";
      #open template this needs to allow directory override like the rest of the confs 
      open(HEADER, "$Config{html_header}") || die "Can not open HTML Header at $Config{html_header}: $!\n";
      my @header = <HEADER>; 
      close HEADER;
      #Expand variables... There must be a better way -mgt 
      for my $header_line (@header) {
         $header_line =~ s/\$([\w\_\-\{\}\[\]]+)/$HTML_var{$1}/g;
         $out_head .= $header_line;
      }

      #FOOTER
      #open template this needs to allow directory override like the rest of the confs 
      open(FOOTER, "$Config{html_footer}") || die "Can not open HTML Footer at $Config{html_header}: $!\n";
      my @footer = <FOOTER>; 
      close FOOTER;
      #Expand variables... There must be a better way -mgt 
      for my $footer_line (@footer) {
         $footer_line =~ s/\$([\w\_\-\{\}\[\]]+)/$HTML_var{$1}/g;
         $out_foot .=  $footer_line;
      } 

      #Set up out_reference
      output("ul","<ul>", "ref_extra") if defined( $index_par );
      foreach ( 0 .. $index_par ) {
         output($_,$reports[$_], "ref") if defined( $reports[$_] );
      }
      output("ul","</ul>", "ref_extra") if defined( $index_par );

   }
   
   if ( $outtype_html ) {
      $index_par++;
      output( $index_par,  "Logwatch End", "start" );
      output( $index_par,  "\n <h3><font color=\"blue\">Logwatch ended at ".  localtime(time) ."</font></h3>\n", "header") if ($printing);
      output( $index_par, "\n", "stop");
   } else {
      output( $index_par, $report_finish, "line") if ($printing);
   }

#Printing starts here $out_mime $out_head $out_reference $out_body $out_foot  
   print OUTFILE $out_mime if $out_mime;
   if ( $Config{'encode'} == 1 ) {
      print OUTFILE encode_base64($out_head) if $out_head;
      print OUTFILE encode_base64($out_reference) if $out_reference;
      foreach ( 0 .. $index_par ) {
         print OUTFILE encode_base64($out_body{$_}) if defined( $out_body{$_} );
         $out_body{$_} = ''; #We should track this down out_body could be an array instead also -mgt
      }
      print OUTFILE encode_base64($out_foot) if $out_foot;
   } else {
      print OUTFILE $out_head if $out_head;
      print OUTFILE $out_reference if $out_reference;
      foreach ( 0 .. $index_par ) {
         print OUTFILE $out_body{$_} if defined( $out_body{$_} );
         $out_body{$_} = '';
      }
      print OUTFILE $out_foot if $out_foot;
   }
#ends here

   if ($Config{'multiemail'} eq 1) {
      close(OUTFILE) unless ($Config{'print'} eq 1);
   }
}

if ($Config{'splithosts'} eq 1) {
   my $Host;
   foreach $Host (@hosts) {
      $printing = '';
      $ENV{'LOGWATCH_ONLY_HOSTNAME'} = $Host;
#      $ENV{'LOGWATCH_ONLY_HOSTNAME'} =~ s/\..*//;
      $Config{'hostname'} = $Host;
      parselogs();
   } # ECP
} else {
   parselogs();
}
close(OUTFILE) unless ($Config{'print'} eq 1);
#############################################################################

exit(0);

sub output {
   my ($index, $text, $type) = @_;
   #Types are start stop header line ref

   if ( $type eq "ref_extra" ) {
      $out_reference .= "$text\n";
   }

   if ( $type eq "ref" ) {
      $out_reference .= "   <li><a href=\"#$index\">$reports[$index]</a>\n";
   }

   if ( $type eq "start" ) {
      $reports[$index] = "$text";
   #SERVICE table headers if ( $index eq 'E' ) { #never happens change out_body from hash back to array
      if ( $outtype_html ) {
         $out_body{$index} .= " <hr>
         <h2><a name=\"$index\">$reports[$index]</a></h2>
         <div class=service>
         <table border=1 width=100%>\n";
      }
   } 

   if ( $type eq "stop" ) {
      if ( $outtype_html ) {
         $out_body{$index} .= "  </table></div>\n";
         $out_body{$index} .= "  <div class=return_link><p><a href=\"#top\">Back to Top</a></p></div>\n";
      }
   }

   if ( $type eq "header" ) {
	   if ($outtype_unformatted) {
	      $out_body{$index} .= "$text \n";
      } elsif ( $outtype_html ) {
         #Covert spaces
         $text =~ s/  / \&nbsp;/go;
         #Covert tabs 1 to 4 ratio
         $text =~ s/\t/ \&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/go;
         #Filters
         $text =~ s/ $//go;
         $text = '&nbsp;' if ( $text eq '' );
         #This will make sure no unbroken string is longer then x characters
         $text =~ s/(\S{$Config{html_wrap}})/$1 /g;
         $out_body{$index} .= "<tr>\n    <th>$text</th>\n   </tr>\n";
      } else {
         $out_body{$index} .=
         sprintf( substr( $text, 0, $format[0] ) . ' ' x( $format[0] - length($text) ) . " \n" );
      }
   }

   if ( $type eq "line" ) {
	   if ($outtype_unformatted or $outtype_mail) {
         $out_body{$index} .= "$text ";
      } elsif ( $outtype_html ) {
         #Covert spaces
         $text =~ s/  / \&nbsp;/go;
         #Covert tabs 1 to 4 ratio
         $text =~ s/\t/ \&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/go;
         #Filters
         $text =~ s/ $//go;
         $text =~ s/</\&lt\;/go;
         $text =~ s/>/\&gt\;/go;
         #This will make sure no unbroken string is longer then x characters
         $text =~ s/(\S{$Config{html_wrap}})/$1 /g;
         #Grey background for spaced output
         if ( $text =~ m/^ / ) {
            $out_body{$index} .= "  <tr>\n    <td bgcolor=#dddddd>$text</td>\n  </tr>\n";
         } else {
            $out_body{$index} .= "  <tr>\n    <th align=left>$text</th>\n  </tr>\n";
         }
      } else {
	      if ( length($text) > $format[0] ) {
	         $out_body{$index} .=
		      sprintf( $text . "\n" . ' ' x $format[0] . ' ' );
	      } else {
	         $out_body{$index} .=
		      sprintf( $text . ' ' x ( $format[0] - length($text) ) . ' ' );
	      }
      }
   }

}

# vi: shiftwidth=3 tabstop=3 et
