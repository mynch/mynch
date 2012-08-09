package Mynch::Tests;
use base qw(Test::Class);
use Test::More;
use Test::Mojo;

sub make_fixture : Test(setup) {
    my $self = shift;

    my $mojo = Test::Mojo->new('Mynch');
    $self->{mojo} = $mojo;
}

1;
