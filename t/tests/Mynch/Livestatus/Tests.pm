package Mynch::Tests;
use base qw(Test::Class);
use Test::More;
use Mynch::Livestatus;

sub make_fixture :Test(setup) {
    my $self = shift;

    my $ls = Mynch::Livestatus->new( config => { server => 'localhost:6557' } );
    $self->{livestatus} = $ls;
}

1;
