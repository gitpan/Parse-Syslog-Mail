#!/usr/bin/perl
use strict;
use Parse::Syslog::Mail;

my $maillog = new Parse::Syslog::Mail shift or die $!;
while(my $log = $maillog->next) {
    for my $field (sort keys %$log) { print "  $field = $$log{$field}\n" }
    print $/
}
