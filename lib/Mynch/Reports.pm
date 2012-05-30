package Mynch::Reports;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use List::MoreUtils qw{ uniq };
use Method::Signatures;

method index {
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

method migration_report {
    $self->migration_data_munin;
    $self->migration_data_mysql;
    $self->migration_data_nrpe;
    $self->migration_data_plugins;
    $self->migration_data_oldnagios;

    $self->render;
}

method migration_data_oldnagios {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ display_name };
    my $query;
    $query .= "GET hosts\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: groups >= x-old-nagios\n";

    my $results_ref = $ls->fetch($query);

    my @hosts = map { $_->[0] } @{ $results_ref };

    $self->stash( oldnagios_hosts => \@hosts );
}

method migration_data_munin {
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

method migration_data_mysql {
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

method migration_data_nrpe {
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

method migration_data_plugins {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_display_name display_name plugin_output };

    my $query;
    $query .= "GET services\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: plugin_output ~ CRITICAL: Return code of .* is out of bounds\n";
    $query .= "Filter: plugin_output ~ No such file or directory\n";
    $query .= "Filter: plugin_output ~ error executing command\n";
    $query .= "Or: 3\n";

    my $results_ref = $ls->fetch( $query );

    $self->stash( plugin_services => $results_ref );
}

1;
