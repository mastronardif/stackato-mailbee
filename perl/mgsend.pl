#!/usr/bin/perl5 -w
use Mail::Box::Manager 2.00;
use LWP::UserAgent;
use HTTP::Request::Common qw(GET);
use HTTP::Request::Common qw(POST);
use Data::Dump ();
use Data::Dumper;
require "./Joemail.pm";

use warnings;
use strict;
#
# Purpose: uses mailgun for http post/mail delevery.
# Originally authored: 01/18/12
#

my %config = do 'myconfig.pl';

# FM begin debug 5/17/12
#my $dbgMail = join("", <DATA>); ##<DATA>;
#$string = join("", <DATA>); 
#print $dbgMail;
#exit 0;
# FM end debug 5/17/12 
my @lines;
=comment
die "please supply a filename as an argument.\n" unless $ARGV[0];

   my $fnMail = $ARGV[0];
   my $MSG;  
   open( $MSG, q{<}, $fnMail ) or die "Can't open $fnMail: $!\n";
   my @lines = <$MSG>;
   close($MSG);
=cut   
@lines = <>;
#@lines = <DATA>;
#####print join ("KKKKK<br/>", @lines);
=comment
   while(<>)
   {
   print;
   }

   #print @lines;
   #print $lines[2];
#print "\n sfsfsdfsfsfsfsf mgsend.pl    \n";
exit;
=cut


#Be warned: writing a MBOX folder may create a new file to replace the old folder. 
#The permissions and owner of the file may get changed by this.

   # for each tag in file ________.

   my $left   = 0;
   my $right  = 0;
   my $mail = "";
   my @maildata;

LINE:   foreach (@lines) {
   #if (/<MESSAGE>(.*?)<\/MESSAGE>/i) # delimeter
   if (/<MYMAIL>/i) # start
   {
      $left = 1;
      next LINE;
   }
   if (/<HEADER>|<\/HEADER>/i) {next LINE;}
   
   if (/<\/MYMAIL>/i)  # end
   {
      #$mail .= $_;
      #push(@maildata, $_);
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
      if ($mail) # FM fix this mess.
      {
         my $msg11 = Mail::Message->read($mail);

         warn "mailgun returned error $!\n" unless mailgunSendIFOK($msg11);
                  
              #warn "Sending returned error $!\n"
              #unless $msg11->send;
              #$folder->addMessage($msg11);
      }
	  
	  #reset
	  $left  = 0;
      $right = 0;
      $mail  = "";
      @maildata = ();
   }
   
}
exit 0;

sub mailgunSendIFOK
{
   my $msg11 = shift;
   my $html = $msg11->decoded;
   
   my $to      = join ", ", $msg11->head->get('To');
   my $From    = $msg11->head->get('From');
   my $Cc      = join ", ", $msg11->head->get('Cc');
   my $Subject = $msg11->head->get('Subject') || "";
   my $MessageId = $msg11->head->get('Message-Id');
   #print $msg11->head; 

   #Safety - avoid Positive feedback will cause system instability.

   #print join "___________, ", $msg11->head->get('To');

   my @wtf = $msg11->head->get('To');
   my $To = join ", ", Joemail::RemoveAddressFromList33(\@wtf);
   if (!$To) { return 0; }

   #print "\n";
   #print "\nTo: \nBefore\t($to) \nAfter\t($To)";

   @wtf = $msg11->head->get('Cc');
   my $tt = join ", ", Joemail::RemoveAddressFromList33(\@wtf);
   my @AnyCCs = ();
   if ($Cc) 
   {
      print "\nCc: \n\t($Cc) \n\t($tt)\n";
      @AnyCCs = ('cc', $tt);
   }

   my $aref =[  from => $From
              , to =>$To
              , subject =>$Subject
              , text =>'hello there'
              , 'h:X-My-Header'=> 'RABIT'
              , 'h:Message-Id' => $MessageId
              , html =>$html
          ];

   my @frmVals = (@$aref, @AnyCCs);
 
   my $url='https://api.mailgun.net/v2/joeschedule.mailgun.org/messages';
   my $ua = LWP::UserAgent->new;
 
   #print "\n====================\n";
   #print join "\n", @frmVals;
   #$config{'joemail@joeschedule.com'}
   my $req = POST $url, \@frmVals;
   #$req->authorization_basic('api', 'key-0-rxwnpe9gllqe6odwxebn79vicgxf76');
   $req->authorization_basic('api', $config{'MGApiKey'});
 
   my $res = $ua->request($req);
  
   print $res->as_string;
   
   return 10;
}
__DATA__
<MYMAIL>
<HEADER>
From: joemail@joeschedule.com
To: Frank Mastronardi <mastronardif@gmail.com>
Subject: Re: debug mgsend.pl
In-Reply-To: <CAAAKxgKEqWkQ_v3kPRhY+3ATgM1ePYcCLtv+-1qtT3T=s=AYsA@mail.gmail.com>
References: <CAAAKxgKEqWkQ_v3kPRhY+3ATgM1ePYcCLtv+-1qtT3T=s=AYsA@mail.gmail.com>
Message-Id: <mailbox-19950-1311902078-753076@www3.pairlite.com>
Date: Thu, 28 Jul 2011 21:14:38 -0400
MIME-Version: 1.0
Content-Type: text/html; charset="UTF-8"

</HEADER>
<TAGS>
http://link.patch.com/5w49.b1/Tiqqt6siFi0MzJThA25a3
</TAGS>
</MYMAIL>
