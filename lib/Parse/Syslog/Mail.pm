package Parse::Syslog::Mail;
use strict;
use Parse::Syslog;

{ no strict;
  $VERSION = '0.01';
}

=head1 NAME

Parse::Syslog::Mail - Parse mailer logs from syslog

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Parse::Syslog::Mail;

    my $parser = Parse::Syslog::Mail->new();
    ...

=head1 DESCRIPTION

As its names implies, C<Parse::Syslog::Mail> presents a simple interface 
to gather mail information from a syslog. It uses C<Parse::Syslog> for 
reading the syslog, and offer the same simple interface. 


=head1 METHODS

=over 4

=item new()

Creates and returns a new C<Parse::Syslog::Mail> object. 
Expects a file path or a C<File::Tail> object as first argument. 
Options can follow as a hash. 

B<Options>

=over 4

=item *

C<year> - 

=item *

C<GMT> - 

=item *

C<repeat> - 

=item *

C<locale> - 

=item *

C<allow_future> - 

=back

B<Examples>

    my $syslog = new Parse::Syslog::Mail '/var/log/syslog', allow_future => 1;

=cut

sub new {
    my $self = {
        syslog => undef, 
    };
    my $class = ref $_[0] ? ref shift : shift;
    bless $self, $class;

    my $file = shift;
    my %args = @_;

    $self->{syslog} = new Parse::Syslog $file, %args;

    return $self
}

=item next()

Returns the next line of the syslog as a hashref, undef when there 
is no more lines. The hashref contains at least the following keys: 

=over 4

=item *

C<timestamp> - Unix timestamp for the event.

=item *

C<id> - Local transient mail identifier. 

=back

Other keys are the corresponding fields from a Sendmail entry. 

B<Example>

    while(my $log = $syslog->next) {
	# do something with $log
    }

=cut

sub next {
    my $self = shift;
    my %mail = ();

    LINE: {
        my $log = $self->{syslog}->next;
        return undef unless defined $log;
        redo unless $log->{program} =~ /^(?:sendmail|postfix)/;
        redo if $log->{text} =~ /^(?:NOQUEUE|STARTTLS)/;
        $log->{text} =~ s/^(\w+):// and my $id = $1;
        redo unless $id;
        my @fields = split ', ', $log->{text};
        %mail = map { s/,$//; s/^ +//; s/ +$//; split /=/ } @fields;
        $mail{id} = $id;
        $mail{timestamp} = $log->{timestamp};
    }
    return \%mail
}

=back

=head1 SEE ALSO

L<Parse::Syslog>

=head1 AUTHOR

SE<eacute>bastien Aperghis-Tramoni E<lt>sebastien@aperghis.netE<gt>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-parse-syslog-mail@rt.cpan.org>, or through the web interface at
L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-P0f>. 
I will be notified, and then you'll automatically be notified 
of progress on your bug as I make changes.

=head1 CAVEATS

Most probably the same as C<Parse::Syslog>, see L<Parse::Syslog/"BUGS">

=head1 COPYRIGHT & LICENSE

Copyright 2005 SE<eacute>bastien Aperghis-Tramoni, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Parse::Syslog::Mail
