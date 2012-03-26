use Mojo::Base -strict;

use Test::More tests => 13;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch');

$t->get_ok('/services')->status_is(200)->content_type_is('application/json')->content_isnt('[]');
$t->get_ok('/services/hostgroup/munin')->status_is(200)->content_type_is('application/json')->content_isnt('[]');
$t->get_ok('/services/hostgroup/acme')->status_is(200)->content_type_is('application/json')->content_is('[]');
