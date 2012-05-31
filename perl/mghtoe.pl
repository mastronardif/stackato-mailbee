#!/usr/bin/perl -w

use URI::Escape;
use Email::Address;
#use URI;
#use Regexp::Common qw/URI/;
use strict;
use warnings;

#print "mghtoe.pl dddddddddddddddddddddddd"; exit;
=comment
  my $fnMail = $ARGV[0];
  open(MSG, $fnMail) or die "Can't open $fnMail: $!\n";
  $data = join('',<MSG>);
  close MSG;
=cut 
my  $data = join('',<>);
  #print "FUCK FUCK ". $data;
  #exit;
my $from; 
$data =~ m/^From:\s+(.*)/im; 
$from = $1 || 'joemail@joeschedule.com';

$from =~ s/<//g;
$from =~ s/>//g;

my @addrs = Email::Address->parse($from);
$from = $addrs[0];


my $ae = " ae=a"; # default

if($data =~ m/<tags(.*?)>/im) {
   $ae = $1;
   #$ae =~ s/^\s+//; #remove leading spaces
   #$ae =~ s/\s+$//; #remove trailing spaces
}
elsif ($data =~ m/&lt;tags(.*?)&gt;/im) {
   $ae = $1;
}
#$ae =~ s/^\s+//; #remove leading spaces
$ae =~ s/\s+$//; #remove trailing spaces


#$data =~ s/(a href=")(.*?)"/$1mailto:joemail\@joeschedule.com\?subject=joemailweb\&body=\%26lt\%3Btags
my $b0 = "http://boilerpipe-web.appspot.com/extract?url=";
my $b1 = "&extractor=ArticleExtractor&output=htmlFragment";
$data =~ s/(a.*?href\s*=\s*")(\s*http:.*?)"/"$1mailto:$from\?subject=joemailweb\&body=\%26lt\%3Btags$ae\%26gt\%3B".uri_escape("<tags$ae>".$2."<\/tags>")."\%26lt\%3B\%2Ftags\%26gt\%3B\""/iegs;

#Fm 2/7/12$data =~ s/(a.*?href\s*=\s*")(\s*http:.*?)"/"$1mailto:$from\?subject=joemailweb\&body=\%26lt\%3Btags%20ae=a\%26gt\%3B".uri_escape("<tags ae=a>".$2."<\/tags>")."\%26lt\%3B\%2Ftags\%26gt\%3B\""/iegs;

#$data =~ 
# fm 12/23/11 s/(a.*?href\s*=\s*")(.*?)"/"$1mailto:joemail\@joeschedule.com\?subject=joemailweb\&body=\%26lt\%3Btags ae=a\%26gt\%3B".uri_escape("<tags>".$2."<\/tags>")."\%26lt\%3B\%2Ftags\%26gt\%3B\""/iegs;
#FM 1/25/12 s/(a.*?href\s*=\s*")(\s*http:.*?)"/"$1mailto:joemail\@joeschedule.com\?subject=joemailweb\&body=\%26lt\%3Btags ae=a\%26gt\%3B".uri_escape("<tags>".$2."<\/tags>")."\%26lt\%3B\%2Ftags\%26gt\%3B\""/iegs;

print $data;

#while (<>) {
#   $users .= $_;
#print ;
#}

exit(0);


=comment

C:\Perl64\bin\lwp-request.bat "http://boilerpipe-web.appspot.com/extract?url=http%3A%2F

%2Fslashdot.org&extractor=CanolaExtractor&output=html" > 000.htm
perl mygrep.pl 000.htm > 002.htm

C:\Perl64\bin\lwp-request.bat            http://slashdot.org > one.000
C:\Perl64\bin\lwp-request.bat            http://slashdot.org > one.000
perl mygrep.pl ONE.txt > ONE.222
perl  -w  -pi.bak -e "s/(a href=")(.*")/$1\mailto:joemail\@joeschedule.com $2 replaceregex"/g;"   

ONE.txt > one.222

http://meyerweb.com/eric/tools/dencoder/
http://boilerpipe-web.appspot.com/extract?url=http%3A%2F

%2Fslashdot.org&extractor=ArticleExtractor&output=html
http://boilerpipe-web.appspot.com/extract?url=http%3A%2F

%2Fslashdot.org&extractor=ArticleExtractor&output=htmlFragment
http://boilerpipe-web.appspot.com/extract?url=http%3A%2F

=cut


