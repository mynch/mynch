package Mynch::Livestatus;
use Mojo::Base 'Mojolicious::Controller';
use Monitoring::Livestatus;
use strict;

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

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );
    $self->render(json => $results_ref);
}

sub servicesbyhostgroup {
    my $self = shift;

    my @columns = qw{ host_groups host_name display_name state
           acknowledged downtimes last_hard_state_change last_check
           next_check last_notification current_attempt
           max_check_attempts plugin_output };

    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );

    if ( $self->param('hostgroup') ) {
        $query .= $self->_filter(
            {   param    => 'hostgroup',
                operator => '>=',
                column   => 'host_groups'
            }
        );
    }

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );

    # $self->render( json => $results_ref );
    $self->stash(columns => \@columns);
    $self->stash(results => $self->_massage($results_ref, \@columns));
    $self->render;
}

sub wallscreen {
    my $self = shift;

    $self->_wallscreen_main;
    $self->_wallscreen_log;
    $self->render;
}


sub filter {
    my $self = shift;
    my $filter;

    if ( $self->session('filter') ) {
        $filter = $self-session('filter');
    }
}

sub _wallscreen_log {
    my $self = shift;

    my $since = time() - 86400; # 1 day

    my @columns = qw{ type time state state_type host_name service_description current_service_current_attempt current_service_max_check_attempts };
    my $query;
    $query .= "GET log\n";
    $query .= sprintf("Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: time >= $since\n";
    $query .= "Filter: type = SERVICE ALERT\n";

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );
    $self->stash(
        log => {
            columns => \@columns,
            data    => $self->_massage($results_ref, \@columns )
        }
    );
}

sub _wallscreen_main {
    my $self = shift;

    my @columns = qw{ host_groups host_name display_name state
           acknowledged downtimes last_hard_state_change last_check
           next_check last_notification current_attempt
           max_check_attempts plugin_output };

    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: state != 0\n";

    my $connection = $self->_connect;
    my $results_ref = $self->_fetch( $connection, $query );

    $self->stash(columns => \@columns);
    $self->stash(results => $self->_massage($results_ref, \@columns));

    return $results_ref;
}

sub _connect {
    my $self = shift;
    my $conn
        = Monitoring::Livestatus->new( server => 'icinga.example.org:6557', );
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

sub _massage {
    my $self        = shift;
    my $src_ref     = shift;
    my $columns_ref = shift;

    my @src     = @$src_ref;
    my @columns = @$columns_ref;
    my @dst;

    foreach (@src) {
        my %tmp;
        @tmp{@columns} = @$_;
        push( @dst, {%tmp} );
    }

    return \@dst;
}

1;
