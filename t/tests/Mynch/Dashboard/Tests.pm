package Mynch::Dashboard::Tests;
use base qw(Mynch::Tests);

sub Load_dashboard_page :Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/dashboard')
        ->status_is(200);
}

1;
