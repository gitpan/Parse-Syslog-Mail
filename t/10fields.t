use strict;
use File::Spec;
use Test::More;
BEGIN { plan 'no_plan' }
use Parse::Syslog::Mail;


my @logs = map { File::Spec->catfile(qw(t logs), $_) } qw(
    sendmail-plain.log
    postfix-plain.log
    sendmail-custom-dsn.log
);

push @logs, map { File::Spec->catfile(File::Spec->rootdir, @$_) } 
    [qw(var log syslog)], 
    [qw(var log maillog)], 
    [qw(var log mail.log)], 
    [qw(var log mail info)], 
;

for my $file (@logs) {
    my $maillog = undef;
    is( $maillog, undef                      , "Creating a new object" );
    eval { $maillog = new Parse::Syslog::Mail $file };
    next if $@;
    ok( defined $maillog                     , " - object is defined" );
    is( ref $maillog, 'Parse::Syslog::Mail'  , " - object is of expected ref type" );
    ok( $maillog->isa('Parse::Syslog::Mail') , " - object is a Parse::Syslog::Mail object" );
    isa_ok( $maillog, 'Parse::Syslog::Mail'  , " - object" );

    while(my $log = $maillog->next) {
        next if $. > 10_000;   # to prevent too long test times
        for my $field (keys %$log) {
            like( $field, '/^[\w-]+$/', " // is field '$field' a word?" )
        }
    }
}
