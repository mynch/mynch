use Mojo::Base -strict;

use Test::More tests => 4;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch');
$t->get_ok('/json')->status_is(200)->content_type_is('application/json');
