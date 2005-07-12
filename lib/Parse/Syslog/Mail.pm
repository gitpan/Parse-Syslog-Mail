package Parse::Syslog::Mail;
use strict;
use Carp;
use Parse::Syslog;

{ no strict;
  $VERSION = '0.05';
}

=head1 NAME

Parse::Syslog::Mail - Parse mailer logs from syslog

=head1 VERSION

Version 0.05

=head1 SYNOPSIS

    use Parse::Syslog::Mail;

    my $maillog = Parse::Syslog::Mail->new('/var/log/syslog');
    
    while(my $log = $maillog->next) {
	# do something with $log
        # ...
    }

=head1 DESCRIPTION

As its names implies, C<Parse::Syslog::Mail> presents a simple interface 
to gather mail information from a syslog. It uses C<Parse::Syslog> for 
reading the syslog, and offer the same simple interface. 


=head1 METHODS

=over 4

=item B<new()>

Creates and returns a new C<Parse::Syslog::Mail> object. 
A file path or a C<File::Tail> object is expected as first argument. 
Options can follow as a hash. Most are the same as for C<Parse::Syslog::new()>. 

B<Options>

=over 4

=item *

C<year> - Syslog files usually do store the time of the event without 
year. With this option you can specify the start-year of this log. If 
not specified, it will be set to the current year.

=item *

C<GMT> - If this option is set, the time in the syslog will be converted 
assuming it is GMT time instead of local time.

=item *

C<repeat> - C<Parse::Syslog> will by default repeat xx times events that 
are followed by messages like C<"last message repeated xx times">. If you 
set this option to false, it won't do that.

=item *

C<locale> - Specifies an additional locale name or the array of locale 
names for the parsing of log files with national characters.

=item *

C<allow_future> - If true will allow for timestamps in the future. 
Otherwise timestamps of one day in the future and more will not be returned 
(as a safety measure against wrong configurations, bogus --year arguments, 
etc.)

=back

B<Example>

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

    croak "fatal: Expected an argument"
      unless defined $file;
    
    croak "fatal: First argument of new() must be a file path of a File::Tail object"
      unless -f $file or $file->isa('File::Tail');
    
    eval { $self->{syslog} = new Parse::Syslog $file, %args };
    if($@) {
        $@ =~ s/ at .*$//;
        croak "fatal: Can't create new Parse::Syslog object: $@";
    }

    return $self
}

=item B<next()>

Returns the next line of the syslog as a hashref, C<undef> when there 
is no more lines. The hashref contains at least the following keys: 

=over 4

=item *

C<host> - hostname of the machine.

=item *

C<program> - name of the program. 

=item *

C<timestamp> - Unix timestamp for the event.

=item *

C<id> - Local transient mail identifier. 

=item *

C<text> - text description.

=back

Other keys are the corresponding fields from a Sendmail entry. 

=over 4

=item *

C<from> - Email address of the sender.

=item *

C<to> - Email addresses of the recipients, coma-separated.

=item *

C<msgid> - Message ID.

=item *

C<relay> - MTA host used for relaying the mail.

=item *

C<status> - Status of the transaction.

=back

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
        redo if $log->{text} =~ /^(?:NOQUEUE|STARTTLS|TLS:)/;
        redo if $log->{text} =~ /prescan: (?:token too long|too many tokens|null leading token) *$/;

        $log->{text} =~ s/^(\w+):// and my $id = $1;       # gather the MTA unique id
        redo unless $id;

        redo if $log->{text} =~ /^\s*(?:[<-]--|[Mm]ilter|SYSERR)/;   # we don't treat these

        $log->{text} =~ s/^\s*([^=]+)\s*$/status=$1/;      # format status messages
        $log->{text} =~ s/collect: /collect=/;             # treat collect messages as field identifiers
        $log->{text} =~ s/(\S+),\s+([\w-]+)=/$1\t$2=/g;    # replace field seperators with tab characters

        my @fields = split /\t/, $log->{text};
        %mail = map {
                s/,$//;  s/^ +//;  s/ +$//;  # cleaning spaces
                s/^stat=/status=/;           # renaming 'stat' field to 'status'
                s/.*\s+([\w-]+=)/$1/;        # cleaning up field names
                split /=/, $_, 2;            # no more than 2 elements
            } @fields;
        $mail{id} = $id;
        map { $mail{$_} = $log->{$_} } qw(host program timestamp text);
    }

    return \%mail
}

=back


=head1 DIAGNOSTICS

=over 4

=item Can't create new %s object: %s

B<(F)> Occurs in C<new()>. As the message says, we were unable to create 
a new object of the given class. The rest of the error may give more information. 

=item Expected an argument

B<(F)> You tried to call C<new()> with no argument. 

=item First argument of new() must be a file path of a File::Tail object

B<(F)> As the message says, you must give to C<new()> a valid (and readable) 
file path or a C<File::Tail> object as first argument. 

=back

=head1 SEE ALSO

L<Parse::Syslog>

=head1 AUTHOR

SE<eacute>bastien Aperghis-Tramoni E<lt>sebastien@aperghis.netE<gt>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-parse-syslog-mail@rt.cpan.org>, or through the web interface at
L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Parse-Syslog-Mail>. 
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
