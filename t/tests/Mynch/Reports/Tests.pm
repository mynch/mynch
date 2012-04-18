package Mynch::Reports::Tests;
use base qw(Mynch::Tests);

sub Load_report_migration_page :Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/report/migration')
        ->status_is(200);
}

1;
