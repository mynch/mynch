use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION   => '0.01',
    PREREQ_PM => {
        'Contextual::Return'      => '0',
        'Date::Format'            => '0',
        'List::MoreUtils'         => '0',
	'Method::Signatures'      => '20110923.1726',
        'Mojolicious'             => '2.82',
        'Monitoring::Livestatus'  => '0',
        'Quantum::Superpositions' => '0',
        'Test::Class'             => '0',
        'Time::Duration'          => '0',
    },
    test      => {TESTS => 't/*.t'}
);
