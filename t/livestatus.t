use Mojo::Base -strict;

use Test::More tests => 7;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch');

$t->get_ok('/hostgroup')->status_is(200)->content_type_is('application/json');
$t->get_ok('/hostgroup/24media')->status_is(200)->content_type_is('application/json');
