package Mynch::Livestatus::Tests;
use base qw(Test::Class);
use Test::More;
use Mynch::Livestatus;

sub make_fixture :Test(setup) {
    my $self = shift;

    my $ls = Mynch::Livestatus->new( server => 'localhost:6557' );
    $self->{ls} = $ls;
}

sub Object  :Test {
    local $TODO = "live currently unimplemented";
};

sub Connect_to_livestatus :Test {
    local $TODO = "live currently unimplemented";
};

1;
