package Mynch::Wallscreen::Tests;
use base qw(Mynch::Tests);

sub Load_wallscreen_page : Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/wallscreen')->status_is(200);
}

sub Load_wallscreen_log_page : Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/wallscreen/log')->status_is(200);
}

sub Load_wallscreen_status_page : Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/wallscreen/status')->status_is(200);
}

sub Load_wallscreen_hostgroups_page : Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/wallscreen/hostgroups')->status_is(200);
}

1;
