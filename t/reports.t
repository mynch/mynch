# -*- perl -*-

use Mojo::Base -strict;

use Test::More tests => 3;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch');

$t->get_ok('/report/migration')
    ->status_is(200);
