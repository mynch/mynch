# -*- perl -*-

use Mojo::Base -strict;

use Test::More tests => 1;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch::Livestatus');
