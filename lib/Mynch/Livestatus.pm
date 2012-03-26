package Mynch::Livestatus;
use Mojo::Base 'Mojolicious::Controller';
use Monitoring::Livestatus;
use strict;

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

sub hostgroups {
    my $self = shift;

    my @columns = qw{name members};

    my $query;
    $query .= "GET hostgroups\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );

    if ( $self->param('hostgroup') ) {
        $query .= $self->_filter(
            { param => 'hostgroup', operator => '=', column => 'name' } );
    }

    $self->app->log->debug( "Query: " . $query );

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );
    $self->render( json => $results_ref );
}

sub servicesbyhostgroup {
    my $self = shift;

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
        $query .= $self->_filter(
            { param => 'hostgroup', operator => '>=', column => 'host_groups' }
        );
    }

    $self->app->log->debug( "Query: " . $query );

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );
    $self->render( json => $results_ref );
}

sub _filter {
    my $self = shift;
    my ($args) = @_;

    my $filter;

    my @groups = split( /,/, $self->param( $args->{'param'} ) );
    my @filters = map {
        sprintf( "Filter: %s %s %s\n",
            $args->{'column'}, $args->{'operator'}, $_ )
    } @groups;

    $filter .= join( "", @filters );
    if ( scalar(@filters) > 1 ) {
        $filter .= sprintf( "Or: %d", scalar(@filters) );
    }

    $self->app->log->debug( "Filter: " . $filter );

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
