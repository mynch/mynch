package Mynch::Wallscreen;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use strict;

sub log_page {
    my $self = shift;

    $self->log_data;
    $self->render;
}

sub log_data {
    my $self = shift;
    my $ls   = Mynch::Livestatus;

    my $since = time() - 600;    # 10 minutes of log data

    my @columns = qw{ type time state state_type host_name
      service_description attempt
      current_service_max_check_attempts };

    my $query;
    $query .= "GET log\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: time >= $since\n";
    $query .= "Filter: type = SERVICE ALERT\n";

    my $connection = $ls->_connect;
    my $results_ref = $ls->_fetch( $connection, $query );

    my $data_ref = $ls->_massage( $results_ref, \@columns );

    $self->stash( log => $data_ref );
}
