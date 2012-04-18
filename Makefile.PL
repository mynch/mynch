use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.01',
  PREREQ_PM => {
      'Mojolicious'    => '2.50',
      'Time::Duration' => '0',
      'Monitoring::Livestatus' => '0',
      'Test::Class' => '0',
      'Quantum::Superpositions' => '0',
      'List::MoreUtils' => '0',
  },
  test      => {TESTS => 't/*.t'}
);
