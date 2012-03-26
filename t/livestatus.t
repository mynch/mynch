# -*- perl -*-

use Mojo::Base -strict;

use Test::More tests => 25;
use Test::Mojo;

use_ok 'Mynch';

my $t = Test::Mojo->new('Mynch');

$t->get_ok('/services')->status_is(200)->content_type_is('application/json')
  ->content_isnt('[]');
$t->get_ok('/services/hostgroup/puppet-nodes')->status_is(200)
  ->content_type_is('application/json')->content_isnt('[]');
$t->get_ok('/services/hostgroup/nonexistant')->status_is(200)
  ->content_type_is('application/json')->content_is('[]');

$t->get_ok('/hostgroups')->status_is(200)->content_type_is('application/json')
  ->content_isnt('[]');
$t->get_ok('/hostgroups/puppet-nodes')->status_is(200)
  ->content_type_is('application/json')->content_isnt('[]');
$t->get_ok('/hostgroups/nonexistant')->status_is(200)
  ->content_type_is('application/json')->content_is('[]');
