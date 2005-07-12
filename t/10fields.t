use strict;
use File::Spec;
use Test::More;
BEGIN { plan 'no_plan' }
use Parse::Syslog::Mail;

my $developer_mode = 0;

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

if($developer_mode) {
    @logs = @ARGV if @ARGV;

    my $local_logs_dir = File::Spec->catdir('workshop', 'logs');
    if(-d $local_logs_dir) {
        push @logs, glob(File::Spec->catfile($local_logs_dir, '*'))
    }
}

for my $file (@logs) {
    my $maillog = undef;
    is( $maillog, undef                      , "Creating a new object" );
    eval { $maillog = new Parse::Syslog::Mail $file };
    next if $@;
    diag(" -> reading $file") if $developer_mode;
    ok( defined $maillog                     , " - object is defined" );
    is( ref $maillog, 'Parse::Syslog::Mail'  , " - object is of expected ref type" );
    ok( $maillog->isa('Parse::Syslog::Mail') , " - object is a Parse::Syslog::Mail object" );
    isa_ok( $maillog, 'Parse::Syslog::Mail'  , " - object" );

    while(my $log = $maillog->next) {
        next if $. > 10_000;   # to prevent too long test times
        ok( defined $log,     " -- line $. => new \$log" );
        is( ref $log, 'HASH', " -- \$log is a hashref" );
        for my $field (keys %$log) {
            like( $field, '/^[\w-]+$/', " ---- is field '$field' a word?" )
        }
        $log->{id}   and like( $log->{id},   '/^\w+$/',  " --- checking 'id'" );
        $log->{from} and like( $log->{from}, '/^(?:\w+|<.*>)$/', " --- checking 'from'" );
    }
}

