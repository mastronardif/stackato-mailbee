#!/usr/bin/perl -wT
use CGI qw(:standard escapeHTML);

#require "./sch00.lib";

use strict "vars";

print "Content-type: text/html\n\n";

my $query = new CGI;

print "Thanks for your inquiry.";
&reply($query);

sub reply {
   my($query) = @_;
   my(@values,$key);

   print "<H2>What you wrote:</H2>";

   foreach $key ($query->param) {
      print "<STRONG>$key</STRONG> -> ";
      @values = $query->param($key);
      print join(", ",@values),"<hr />\n";
  }
}
