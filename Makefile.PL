use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.01',
    PREREQ_PM => {
        'List::MoreUtils'         => '0',
        'Mojolicious'             => '2.50',
        'Monitoring::Livestatus'  => '0',
        'Quantum::Superpositions' => '0',
        'Test::Class'             => '0',
        'Time::Duration'          => '0',
    },
    test      => {TESTS => 't/*.t'}
);
