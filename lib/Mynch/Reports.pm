package Mynch::Reports;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use List::MoreUtils qw{ uniq };

sub index {
    my $self = shift;
    my $reports = [
        {
            name  => 'Icinga migration',
            route => '/report/migration',
            description => 'Work needed in order to migrate to Icinga from Nagios',
        },
    ];

    $self->stash( reports => $reports );
    $self->render;
}

sub migration_report {
    my $self = shift;

    $self->migration_data_munin;
    $self->migration_data_mysql;
    $self->migration_data_nrpe;
    $self->migration_data_plugins;

    $self->render;
}

sub migration_data_munin {
    my $self = shift;
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ hostgroup_name };

    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: hostgroup_name != x-old-nagios\n";
    $query .= "Stats: state = 3\n";
    $query .= "Stats: plugin_output = UNKNOWN: No current data from munin\n";
    $query .= "StatsAnd: 2\n";

    my $results_ref = $ls->fetch( $query );

    my @sorted = sort { $b->[1] <=> $a->[1]} @{ $results_ref };
    $self->stash( munin_hostgroups => \@sorted );
}

sub migration_data_mysql {
    my $self = shift;
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_display_name display_name };

    my $query;
    $query .= "GET services\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: plugin_output ~ ^Access denied for user '.*'\@'.*'\n";

    my $results_ref = $ls->fetch( $query );

    my @sorted = sort { $a->[0] eq $b->[0]} @{ $results_ref };
    $self->stash( mysql_services => \@sorted );
}

sub migration_data_nrpe {
    my $self = shift;
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_display_name };

    my $query;
    $query .= "GET services\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: plugin_output = CHECK_NRPE: Error - Could not complete SSL handshake.\n";

    my $results_ref = $ls->fetch( $query );

    # ewww...
    my @sorted = uniq map {@$_} sort { $a->[0] eq $b->[0]} @{ $results_ref };
    $self->stash( nrpe_hosts => \@sorted );
}

sub migration_data_plugins {
    my $self = shift;
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_display_name display_name plugin_output };

    my $query;
    $query .= "GET services\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: plugin_output ~ CRITICAL: Return code of .* is out of bounds\n";

    my $results_ref = $ls->fetch( $query );

    $self->stash( plugin_services => $results_ref );
}

1;
