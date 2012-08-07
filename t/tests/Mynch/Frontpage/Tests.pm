package Mynch::Frontpage::Tests;
use base qw(Mynch::Tests);

sub Load_frontpage :Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/')
        ->status_is(200);
}

1;
