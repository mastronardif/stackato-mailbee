#!/usr/bin/perl5 -w
use strict 'vars';
use warnings;
use HTML::TokeParser;
##use HTML::SimpleLinkExtor;
use Regexp::Common qw/URI/;
use HTML::Entities;
use Joemail;
use URI;

# need to install use Data::Validate::URI qw(is_web_uri  );
# not yet, maybe latter use HTML::LinkExtor;

my $debug=0;
=comment
if ($#ARGV == 1)
{
   if ($ARGV[1] =~ m/debug/i)
   {
      $debug=1;
   }
}

if ($#ARGV < 0)
{
   &usage();
   exit (1);
}
=cut

=comment
my $gFromJSAdmin="joemail\@joeschedule.com"; 
   my $fnMail = $ARGV[0];

   open(MSG, $fnMail) or die "Can't open $fnMail: $!\n";
   my @lines = <MSG>;
   close(MSG);
=cut
my @lines = <>;

#FM 1/27/12 print 'ssssssssssssss'.join "", @lines; exit;
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
         ##if (&validate($mail))
         if (Joemail->validate($mail))
         {
            if ($msgNo > 1) {print "\n<MESSAGE>$msgNo</MESSAGE>\n";}

            &expand(@maildata);
            $msgNo++;
         }
         else 
         {
            if ($msgNo > 1) {print "\n<MESSAGE>$msgNo</MESSAGE>\n";}

   my $data = join('', @maildata);
   $data =~ /(<HEADER>.*?<\/HEADER>)/is;
   my $head = $1 || "no header\n";
   print "<MYMAIL>\n$head\n";
   print "Failed validate. Invalid joemail tags!\n";

   print "<TAGS>\n";
   print "http://yahoo.com\n";
   print "</TAGS>\n";
   print "</MYMAIL>\n";
#            &expand(@maildata);
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


# Expand tags - get urls.  FM move this to Joemail.pm when you get a chance.
sub expand
{
   my @mail = @_;
   my $data = join('', @mail);
   #my $data = join('', @_);
   #sub expand($mail)
#   my @mail01 = shift;
#   @_
   my $left   = 0;
   my $right  = 0;
   my $leftTags   = 0;
   my $rightTags  = 0;

#
my %urls; # unique urls, no duplicates.
my %urls77; # unique urls, no duplicates.
#my $theTags;
#my $data = join('', @_);

#print $data;
my $head="";

if ($debug)
{
   print ("\ndata aaaa\n");
   print ($data);
   print ("\ndata bbbb\n");
}


$data =~ /(<HEADER>.*?<\/HEADER>)/is;
$head = $1 || "no header\n";
#print $head;
#exit(9);


#$data =~ s/\s//gs;

#print "\n________EEEE____________\n";print $data; print "\n________GGGG____________\n";

=comment # 1/15/12 FM bug unearthed by mailgun
# Fm 9/9/11 ad if statement.
#=comment
#if ($data !~ /<\/TAGS>/is)
{
   $data =~ s/&lt;/</igs;
   $data =~ s/&gt;/>/igs;
   $data =~ s/<\/\s*tags\s*>/<\/tags>/igm;
}
#=cut
# Fm 9/9/11
=cut # 1/15/12 FM bug unearthed by mailgun

#print "\n________HHHH____________\n";print $data; print "\n________IIII____________\n";
my %joeys = Joemail->GetUrlsNAttribs($data, "tags");

#print "\n________FxFxFxF____________\n"; print $data; print "\n________1111111____________\n";

if ($debug)
{
print "\noemailJoemailJoemail_00\n";
   while( my ($k, $v) = each %joeys ) {
      print "\t ****** key: $k, value: $v \n";
   }
print "\n----JoemailJoemailJoemail_11\n";
}

   while( my ($k, $v) = each %joeys ) 
   {
      if ($k !~ /http/i)
      #if ($k =~ /^\/\//)
      {        
      
      
         my $fix = "http://".$k;
         $urls77{$fix} = $v;
         next;
      }
      
      #get just the urls.
      if ($k =~ /https?:\/\//)
      {
         $urls77{$k} = $v;
      }
      
   }


if (!keys( %urls77 ))
{
   print "<MYMAIL>\n$head\n";
   print "Failed expand should have failed validate. Invalid no joemail tags!\n";

   print "<TAGS>\n";
   print "http://nytimes.com\n";
   print "</TAGS>\n";
   print "</MYMAIL>\n";

   return 0;
}

   my $cnt=0;
   while( my ($key, $val) = each %urls77 ) 
   {
      my $headA = $head;
      if ($cnt)
      {
         #$headA =~ s/(Message-Id: .*)/$1-$cnt/ig
         $headA =~ s/(Message-Id: .*)/Message-Id: BOBY-$cnt/ig
      }

      print "<MYMAIL>\n$headA\n";
   
      my $tag = "TAGS";
      if ($val) { $val=~ s/^\s+|\s+$//g; $tag = sprintf("TAGS %s", $val); }
         print "<$tag>\n";
         print "$key\n";
         print "</TAGS>\n";
         print "</MYMAIL>\n";

         $cnt++;
      }
   return 1;
}
