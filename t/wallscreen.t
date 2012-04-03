# -*- perl -*-

use Mojo::Base -strict;

use Test::More tests => 10;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch');

$t->get_ok('/wallscreen')
    ->status_is(200)
    ->text_is('html head title' => 'Mynch');
$t->get_ok('/wallscreen/log')
    ->status_is(200);
$t->get_ok('/wallscreen/status')
    ->status_is(200);
$t->get_ok('/wallscreen/hostgroups')
    ->status_is(200);
