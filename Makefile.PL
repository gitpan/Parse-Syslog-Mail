use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Parse::Syslog::Mail',
    AUTHOR              => 'Sébastien Aperghis-Tramoni <sebastien@aperghis.net>',
    VERSION_FROM        => 'lib/Parse/Syslog/Mail.pm',
    ABSTRACT_FROM       => 'lib/Parse/Syslog/Mail.pm',
    PREREQ_PM => {
        'Parse::Syslog' => 0,
        'Test::More' => 0,
        'Test::Exception' => 0,
        'Test::Warn' => 0,
    },
    PL_FILES            => {},
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Parse-Syslog-Mail-*' },
);
