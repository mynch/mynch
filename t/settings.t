# -*- perl -*-

use Mojo::Base -strict;

use Test::More tests => 7;
use Test::Mojo;

use_ok 'Mynch';
use_ok 'Mynch::Livestatus';
use_ok 'Quantum::Superpositions';

my $t = Test::Mojo->new('Mynch');

$t->get_ok('/settings')
    ->status_is(200);
$t->get_ok('/settings/edit')
    ->status_is(200);
