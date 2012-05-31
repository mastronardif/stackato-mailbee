use strict;
use warnings;

use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::URLMap;
use CGI::Application::PSGI;
use AppCore;

my $handler = sub {
  my $env = shift;
  my $app = AppCore->new({ QUERY => CGI::PSGI->new($env) });
  CGI::Application::PSGI->run($app);
};

builder {
  enable 'Plack::Middleware::ContentLength';
  $handler;
};