use strict;
use File::Spec;
use Test::More;
BEGIN { plan 'no_plan' }
use Parse::Syslog::Mail;

my $maillog = undef;
is( $maillog, undef                      , "Creating a new object" );
$maillog = new Parse::Syslog::Mail File::Spec->catfile(qw(t sendmail.log));
ok( defined $maillog                     , " - object is defined" );
is( ref $maillog, 'Parse::Syslog::Mail'  , " - object is of expected ref type" );
ok( $maillog->isa('Parse::Syslog::Mail') , " - object is a Parse::Syslog::Mail object" );
isa_ok( $maillog, 'Parse::Syslog::Mail'  , " - object" );

my %mail = (
    j061bW9V000809 => {
        from => 'maddingue',  to => 'cpan-testers@perl.org',  
        msgid => '<200501060137.j061bW9V000809@jupiter.maddingue.net>', 
        size => 2039,  mailer => 'relay'
    }, 

    j061bXn5000812 => {
        from => '<maddingue@jupiter.maddingue.net>',  to => '<cpan-testers@perl.org>',  
        msgid => '<200501060137.j061bW9V000809@jupiter.maddingue.net>', 
        size => 2262,  mailer => 'esmtp'
    }, 
);

while(my $log = $maillog->next) {
    my $id = $log->{id};
    if(exists $mail{$id}) {
        ok( exists $mail{$id} , "id $id" );
        map { exists $mail{$id}{$_} and is( $log->{$_}, $mail{$id}{$_}, "  field $_" ) } keys %$log;
    }
}

