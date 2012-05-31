#!/usr/bin/perl -w
use strict "vars";
use warnings;
#print "\nBEGIN ENV in jm002a.pl = ". $ENV{'WTF'} . "END ENV"; #exit;
my $data = $ENV{'WTF'};
if ($data)
{
   print $data;
}
#print "10101010101";