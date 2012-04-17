# -*- perl -*-
use Mojo::Base -strict;

use Test::More tests => 3;
use Test::Mojo;

use_ok 'Mynch';
use_ok 'List::MoreUtils';
use_ok 'Monitoring::Livestatus';
