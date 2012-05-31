#!/usr/bin/perl5 -w
use strict 'vars';
use warnings;
use HTML::TokeParser;
##use HTML::SimpleLinkExtor;
use HTML::Entities;
use Regexp::Common qw/URI/;
#use Joemail;
require "./Joemail.pm";

my $debug=0;
if ($#ARGV == 1)
{
   if ($ARGV[1] =~ m/debug/i)
   {
      $debug=1;
   }
}

#print "\n($#ARGV)\n";
#print "\n$debug+4";
#print "\n$ARGV[1]\n";

=comment
if ($#ARGV < 0)
{
   &usage();
   exit (1);
}

#   my $gFromJSAdmin="joemail\@joeschedule.com";
   my $fnMail = $ARGV[0];

   open(MSG, $fnMail) or die "Can't open $fnMail: $!\n";
   my @lines = <MSG>;
   close(MSG);
=cut
   
my @lines = <>;

#   my $users;
#   while (<DATA>) {
#      $users .= $_;
#   }
    
   # for each tag in file ________.

   my $msgNo = 1;


   my $left   = 0;
   my $right  = 0;
   my $mail;
   my @maildata;

LINE:   foreach (@lines) {
      if (/<MYMAIL>/i) # start
      {
         $mail .= $_;
         push(@maildata, $_);

         $left = 1;
         next LINE;
      }

      if (/<\/MYMAIL>/i)  # end
      {
         $mail .= $_;
         push(@maildata, $_);
         $right = 1;
         #next LINE;
      }

      if ($left && !$right)
      {
         $mail .= $_;
         push(@maildata, $_);
      }

      if ($left && $right)
      {

	 ###########################
         # Validate!!!!!!!!!!!!!!! #
	 ###########################
         #if (&validate($mail))
         if ($debug){print "\n____\n$mail\n____\n";}
         
         if (Joemail->validate($mail))
         {
            #if ($msgNo > 1) {print "\n<MESSAGE>$msgNo</MESSAGE>\n";}

            &expand(@maildata);
            $msgNo++;
         }

         $left  = 0;
         $right = 0;
         $mail  = "";
         @maildata = ();
      }
   }

sub usage
{
   print("usage: $0 <input mail file>\n");
   return 1;
}
=comment
sub validate()
{
   my $left = shift;
   
   return Joemail->validate($left);
}
=cut

# Expand tags - get urls.
sub expand
{
   #sub expand($mail)

   my $data = join('', @_);
#print $data; exit;
   my %urls77; # unique urls, no duplicates.

   my %joeys = Joemail->GetUrlsNAttribs($data, "tags");
   #my %joeys = Joemail::GetUrlsNAttribs($data, "tags");

if ($debug)
{
print "\nCCCCCCCCC expand() %joeys CCCCCCCCCCCCC________\n";

print "\nJoemailJoemailJoemail_00\n";
   while( my ($k, $v) = each %joeys ) {
      print "\t ****** key: $k, value: $v \n";
   }
print "\n----JoemailJoemailJoemail_11\n";
}

my $head; 
$data =~ /(<HEADER>.*?<\/HEADER>)/is;
   $head = $1 || "no header\n";
   $head=~s/^\s+//;
   $head=~s/\s+$//;
print "<MYMAIL>\n".$head."\n";
   
=comment
   $data =~ /<HEADER>(.*?)<\/HEADER>/is;
   
#if($debug == 1)
{
   $head = $1 || "no header\n";
   $head=~s/^\s+//;
   $head=~s/\s+$//;

#   $head =~s/\n+/\n/g;
   print "$head\n\n";
}
=cut

=comment
#if ($debug)
{
print "\nJoemailJoemailJoemail_00\n";
   while( my ($k, $v) = each %joeys ) {
      print "\t ****** key: $k, value: $v \n";
   }
print "\n----JoemailJoemailJoemail_11\n";
}
=cut

   while( my ($k, $v) = each %joeys ) 
   {
      if ($k =~ /^\/\//)
      {        
         my $fix = "http:".$k;
         $urls77{$fix} = $v;
         next;
      }
      
      #get just the urls.
      if ($k =~ /https?:\/\//)
      {
         $urls77{$k} = $v;
      }
      
   }


   while( my ($key, $val) = each %urls77 ) 
   {
      my $tag = "TAGS";
      if ($val) { $val=~ s/^\s+|\s+$//g; $tag = sprintf("TAGS %s", $val); }
      #FM 2/9/12 $tag = "<$tag>$key</TAGS>";
      $tag = "<$tag>$key\n</TAGS>";
      
      my $clArgs = Joemail->TagAttribsToCLargs($tag, "tags");
    
#print "\n++++++++++++ $tag +++++++++++++\n";
#$tag =~ s/tags/RTAGS/igs;
#print Encode::decode($tag);
#print encode_entities($tag);
#print "<br/>\n" . encode_entities($tag) . "\n<br/>\n";

#print "___________.pl  $clArgs  $key\n";
      #print "$tag\n";
      #print "$key\n";
      #print "</TAGS>\n";
      
=comment
print "<br/>\n<RTAGS>\n<br/>\n";
   print "($key)\n<br/>\n";

   # 1st attempt to show the most meanigful string from the url.
   my @array = split('/',$key);
   # sort the array by descending value length
   @array = sort { length $b > length $a } @array;
   print "\n Brief: $array[0]\n" unless !$array[0];


print "\n<br/>\n</RTAGS>\n<br/>\n";
print "<hr></hr>";
=cut

if ($debug)
{
   print "perl ./dos_myget02.pl $clArgs  '$key'";exit;
}
##open(MYDATA, "perl ./dos_myget02.pl $clArgs  '$key' |") or print "Can't fork for myget01: $!\n";

#open(MYDATA, "perl ./dos_myget02.pl http://yahoo.com |") or print "Can't fork for myget01: $!\n";
my $MYDATA;
open($MYDATA, "perl ./dos_myget03.pl $clArgs  '$key' |") or print "Can't fork for myget01: $!\n";
#fm 3/20/12 open($MYDATA, "perl ./dos_myget02.pl $clArgs  '$key' |") or print "Can't fork for myget01: $!\n";

#open(MYDATA, "perl ./dos_myget02.pl '$url33' |") or print "Can't fork for myget01: $!\n";
print <$MYDATA>;
close($MYDATA);

print "<b>Thank you for using joemailweb.</b>";
print "<hr></hr>";
print encode_entities($tag);
print "\n</MYMAIL>\n"

#print "<FONT SIZE=\"-1\"><br/>\n<RTAGS>\n<br/>\n";
#print "($key)\n<br/>\n";
#print "\n<br/>\n</RTAGS>\n<br/></FONT>\n";
#print "<hr></hr>";
   }
}
