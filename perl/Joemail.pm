package Joemail;
use strict;
use warnings;
 
require HTML::Parser;

my @_gaUrls; # urls, attrib pairs.
my @_gaUrls22; # urls, attrib pairs.
#my $_gTag = "TAGS";   # tag ie <tags a=b> bla bla </tags>
my @_gTags = ("TAGS");   # tag ie <tags a=b> bla bla </tags>

#####################################################

sub a_start_handler22
{
    my($self, $tag, $attr) = @_;
    ##return unless $tag eq $_gTag
    return unless (grep {$_ eq $tag} @_gTags);
    
    
    #return unless exists $attr->{href};
    #print "A $attr->{href}\n";
    #print "A $attr->{e}\n" if $attr->{e};
    
    my $myattribs = "";
my $mytext = ""; #$tag;
    
    if($attr)
    {
       while( my ($k, $v) = each %$attr )
       {
          #print "\t -$k $v ", "\t ****** key: $k, value: $v \n";
          $myattribs .= "-$k $v ";
          
          $mytext .= " $k = \"$v\"";
       }
    }
    push(@_gaUrls22, $attr || "");
    #push(@_gaUrls, $myattribs);
    push(@_gaUrls22, $mytext);
    
#print "\njoemail.pm\n $mytext    ZZZZ\n";

    $self->handler(text  => [], '@{dtext}' );
#    $self->handler(start => \&img_handler);
    $self->handler(end   => \&a_end_handler, "self,tagname");
}


sub a_start_handler
{
    my($self, $tag, $attr) = @_;
    ##return unless $tag eq $_gTag
    return unless (grep {$_ eq $tag} @_gTags);
    
    
    #return unless exists $attr->{href};
    #print "A $attr->{href}\n";
    #print "A $attr->{e}\n" if $attr->{e};
    
    my $myattribs = "";
my $mytext = ""; #$tag;
    
    if($attr)
    {
       while( my ($k, $v) = each %$attr )
       {
          #print "\t -$k $v ", "\t ****** key: $k, value: $v \n";
          $myattribs .= "-$k $v ";
          
          #FM 9/11/11 $mytext .= " $k = \"$v\"";
          $mytext .= " $k = $v";
       }
    }
    #push(@_gaUrls, $myattribs);
    push(@_gaUrls, $mytext);
    
#print "\njoemail.pm\n $mytext    ZZZZ\n";

    $self->handler(text  => [], '@{dtext}' );
#    $self->handler(start => \&img_handler);
    $self->handler(end   => \&a_end_handler, "self,tagname");
}

sub img_handler
{
    my($self, $tag, $attr) = @_;
#print $self, $tag, $attr;
    
    return unless $tag eq "img";
    push(@{$self->handler("text")}, $attr->{alt} || "[IMG]");
}

sub a_end_handler
{
    my($self, $tag) = @_;
    my $text = join("", @{$self->handler("text")});

    # Fm 1/15/12 bug unearthed by mailgun 
    $text =~ s/>+//;
    # Fm 1/15/12 bug unearthed by mailgun 

    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
=comment    
    $text =~ s/\s+/ /g;
=cut    
    #print "T $text\n";
    push(@_gaUrls, $text);

    $self->handler("text", undef);
    $self->handler("start", \&a_start_handler);
    $self->handler("end", undef);
}

#####################################################


#my clArgs = = Joemail->TagAttribsToCLargs($tag, "tags");
sub TagAttribsToCLargs
{
   my($caller, $src, @tags) = @_;
   my $retval = "";
   my $clArgs = "";
   @_gTags = @tags; 
   
   @_gaUrls22 = ();
   my $p = HTML::Parser->new(api_version => 3,
           start_h => [\&a_start_handler22, "self,tagname,attr"],
           #report_tags => [$_gTag],
           report_tags => [@_gTags],
           ##report_tags => [@gTags)],
           #report_tags => [qw(a img)],
          );
   $p->parse($src);

   #for (my $idx = 0; $idx < @_gaUrls; $idx += 2)
   for (my $idx = 0; $idx < @_gaUrls22; $idx += 2)
   {
      #print "\nattrib 00\n";
      #$retval = $_gaUrls[$idx];
      $retval = $_gaUrls22[$idx];
      while( my ($k, $v) = each %$retval )
      {
         $clArgs .= "-$k $v ";
         #print "\n$clArgs\n";
      }
      
      #print "\nattrib 11\n";
   }
   @_gaUrls22 = ();
   
   return $clArgs;
   
}

# Get the text and the attribs between the Tags.
#%urlsNattribs = GetUrlsNAttribs($header, "tags");
sub GetUrlsNAttribs
{
   #my($caller, $src, $tag) = @_;
   my($caller, $src, @tags) = @_;
   #print "$caller\n";
   #print "$src\n";
   #print join "\n", @tags;
   #return;

   ## FM 1/16/12 
   $src = Joemail->_private_KludgeCleanHTML($src);

   
   @_gTags = @tags; #gw("fff", "dddd"); ##(@tags) || ("tags");
   #print join "\n", @_gTags;    return;
   
   @_gaUrls = ();
   
   my $p = HTML::Parser->new(api_version => 3,
        start_h => [\&a_start_handler, "self,tagname,attr"],
        #report_tags => [$_gTag],
        report_tags => [@_gTags],
        ##report_tags => [@gTags)],
        #report_tags => [qw(a img)],
       );
   $p->parse($src);

   my %urlsNattribs; # unique urls, no duplicates.
   for (my $idx = 0; $idx < @_gaUrls; $idx += 2)
   {
      #Fm 3/13/12 $urlsNattribs{$_gaUrls[$idx+1]} = $_gaUrls[$idx];
	  #Fm 3/13/12 begin
	  {
	  my $attrib = $_gaUrls[$idx];
	  $attrib =~ s/\+/ /g;
	  $urlsNattribs{$_gaUrls[$idx+1]} = $attrib;
	  }
	  #Fm 3/13/12 end
	  
   }
   @_gaUrls = ();

   return %urlsNattribs;
}

# Remove address from list.  Prevents positive feedback in mailbee system.
my @BlackListExcludes = ('joeschedule.com', 'mailgun.org', 'mailgun.com');
sub RemoveAddressFromList33
{
   my ($x) = @_;

   my @results = ();

   if (!$x) {return @results }

   unless (@_ == 1 && ref($x) eq 'ARRAY') {
          return @results;
          #die "usage: RemoveAddressFromList ARRAYREF1 ARRAYREF2";
   }

   my $skips = join "|", @BlackListExcludes;

   my $kk=0;
   foreach (@$x)
   {
      my @aaa = split( ',\s*', $_);

      foreach (@aaa)
      {
         if (!/$skips/)
         {
            $results[$kk++] = $_;
         }
      }
   }

    return @results;
}


sub RemoveAddressFromList()
{       #RemoveAddressFromList(@cc, "*.joeschedule.com")
   my ($x, $y) = @_;

   my @results = ();

   if (!$x || !$y) {return @results }
   #if (!$y ) {return @$x }

   unless (@_ == 2 && ref($x) eq 'ARRAY' && ref($y) eq 'ARRAY') {
          return @results;
          #die "usage: RemoveAddressFromList ARRAYREF1 ARRAYREF2";
   }

   my $skips = join "|", @$y;

   my $kk=0;
   foreach (@$x)
   {
      my @aaa = split( ',\s*', $_);

      foreach (@aaa)
      {
         if (!/$skips/)
         {
            $results[$kk++] = $_;
         }
      }
   }

    return @results;
}

sub say_hello {
    print "Hi Joemail.pm!\n";
    GetUrlsNAttribs("header", "tags");
}

sub _private_KludgeCleanHTML_REMOVE_ME
{
   #my ($s, %args) = @_;
   #die "Error: Private method called" unless (caller)[0]->isa( ref($s) );
   #warn "OK: Private method called by " . (caller)[0];

   my ($s, $src) = @_;

print "\n\n";
   print "\n BEGIN sub _private_KludgeCleanHTML\n";
   print "\$src($src)";
print "\n END sub _private_KludgeCleanHTML\n";


   #my($caller, $src, @tags) = @_;

   if ($src !~ /<\/TAGS>/is)
   {
   print "\n\n";
   print "\n BEGIN sub _private_KludgeCleanHTML\n";
   print "\$src($src)";
   print "\n END sub _private_KludgeCleanHTML\n";
      $src =~ s/&lt;/</igs;
      $src =~ s/&gt;/>/igs;
      $src =~ s/<\/\s*tags\s*>/<\/tags>/igm;
   }

   return $src;
}

sub _private_KludgeCleanHTML
{
   #my ($s, %args) = @_;
   #die "Error: Private method called" unless (caller)[0]->isa( ref($s) );
   #warn "OK: Private method called by " . (caller)[0];

   my ($s, $src) = @_;


   #my($caller, $src, @tags) = @_;

   if ($src !~ /<\/TAGS>/is)
   {
      $src =~ s/&lt;/</igs;
      $src =~ s/&gt;/>/igs;
      $src =~ s/<\/\s*tags\s*>/<\/tags>/igm;
   }

   return $src;
}

sub _private_func {
  my ($s, %args) = @_;
  die "Error: Private method called"
    unless (caller)[0]->isa( ref($s) );

  warn "OK: Private method called by " . (caller)[0];
}

# validate <tags>...</tags>
sub validate()
{
   my($caller, $left) = @_;
   my $retval = 0;

   # Check for tags
   # Fm 1/16/12
   $left = Joemail->_private_KludgeCleanHTML($left);
=comment
if ($left !~ /<\/TAGS>/is)
{
   $left =~ s/&lt;tags&gt;/<TAGS>/igs;
   $left =~ s/&lt;\/tags&gt;/<\/TAGS>/igs;
}
=cut

#Fm 1/15/12 I don't think this is needed!!! A new bug unearthed w/ mailgun
=comment
$left =~ s/&lt;/</igs;
$left =~ s/&gt;/>/igs;
$left =~ s/<\/\s*tags\s*>/<\/tags>/igm;
#print "\n________CCCC____________\n";print $left;print "\n________DDDD____________\n";
=cut #Fm 1/15/12 I don't think this is needed!!! A new bug unearthed w/ mailgun

my %joeys = Joemail->GetUrlsNAttribs($left, "tags");

#print "\naaJoemailJoemailJoemail_00\n";
#   while( my ($k, $v) = each %joeys ) {
#      print "\t ****** key: $k, value: $v \n";
#   }
#print "\nbbJoemailJoemailJoemail_11\n";

   #FM you could do a quick check to see if site exists not a full request but a active link.
   while( my ($k, $v) = each %joeys ) {
      $retval++;  #FM for not let it do lite validation, just have the tags w/ any data.
      if ($k =~ /http/mi)
      {
            $retval++;
      }
   }
      
   return $retval;
}

1;
