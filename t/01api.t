use strict;
use Test::More;
BEGIN { plan tests => 9 }
use File::Spec;
use Parse::Syslog::Mail;

# check that the following functions are available
ok( defined \&Parse::Syslog::Mail::new  ); #01
ok( defined \&Parse::Syslog::Mail::next ); #02

# create an object
my $parser = undef;
eval { $parser = new Parse::Syslog::Mail File::Spec->catfile('t','sendmail.log') };
is( $@, ''                              ); #03
ok( defined $parser                     ); #04
ok( $parser->isa('Parse::Syslog::Mail') ); #05
is( ref $parser, 'Parse::Syslog::Mail'  ); #06
isa_ok( $parser, 'Parse::Syslog::Mail'  ); #07

# check that the following object methods are available
is( ref $parser->can('new'),     'CODE' ); #08
is( ref $parser->can('next'),    'CODE' ); #09
