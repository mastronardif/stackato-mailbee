use strict;
use warnings;

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::URLMap;

my $sub = CGI::Compile->compile("perl/each.pl");
my $app = CGI::Emulate::PSGI->handler($sub);