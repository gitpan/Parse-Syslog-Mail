use strict;
use Test::More;
use Test::Exception;
use Test::Warn;
BEGIN { plan tests => 3 }
use Parse::Syslog::Mail;

my $maillog = undef;
my $fake_file = 'no such file';
my $fake_object = bless {}, 'Fake::Object';

throws_ok {
    $maillog = new Parse::Syslog::Mail
} '/^fatal: Expected an argument/', 
  "calling new() with no argument";

throws_ok {
    $maillog = new Parse::Syslog::Mail $fake_file
} '/^fatal: First argument of new\(\) must be a file path of a File::Tail object/', 
  "calling new() with an argument that looks like a file";

throws_ok {
    $maillog = new Parse::Syslog::Mail $fake_object
} '/^fatal: First argument of new\(\) must be a file path of a File::Tail object/', 
  "calling new() with an argument that looks like an object";

