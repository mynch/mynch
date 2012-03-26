package Mynch::Livestatus;
use Mojo::Base 'Mojolicious::Controller';

use Monitoring::Livestatus;

sub content {
    my $self = shift;


    my @columns = (
        'host_name',              'host_groups',
        'last_hard_state_change', 'display_name',
        'state',                  'plugin_output',
        'acknowledged',           'downtimes',
        'last_check',             'next_check',
        'last_notification',      'current_attempt',
        'max_check_attempts'
    );

    my $query =
      sprintf( "GET servicesbyhostgroup\nColumns: %s\n",
        join( " ", @columns ) );
    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );
    return $results_ref;
}

sub servicesbyhostgroup {
    my $self      = shift;

    my $hostgroup = $self->param('hostgroup');

    if   ($hostgroup) { $self->app->log->debug( "Hostgroup: " . $hostgroup ); }
    else              { $self->app->log->debug("All hostgroups"); }

    my @columns = (
        'host_name',              'host_groups',
        'last_hard_state_change', 'display_name',
        'state',                  'plugin_output',
        'acknowledged',           'downtimes',
        'last_check',             'next_check',
        'last_notification',      'current_attempt',
        'max_check_attempts'
    );
    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );

    if ($hostgroup) {
        $query .= $self->_filter_host_group;
    }

    $self->app->log->debug("Query: " . $query);

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );
    $self->render( json => $results_ref );
}

sub _filter_host_group {
    my $self = shift;

    my $filter;

    my @groups = split(/,/, $self->param('hostgroup'));
    my @filters = map { sprintf("Filter: host_groups >= %s\n", $_) } @groups;

    $filter .= join("",@filters);
    if (scalar(@filters)>1) {
        $filter .= sprintf("Or: %d", scalar(@filters));
    }

    return $filter;
}

sub _connect {
    my $self = shift;
    my $conn =
      Monitoring::Livestatus->new( server => 'icinga.example.org:6557', );
    return $conn;
}

sub _fetch {
    my $self  = shift;
    my $conn  = shift;
    my $query = shift;

    my $results_ref = $conn->selectall_arrayref($query);

    if ($Monitoring::Livestatus::ErrorCode) {
        croak($Monitoring::Livestatus::ErrorMessage);
    }
    return $results_ref;
}

1;
