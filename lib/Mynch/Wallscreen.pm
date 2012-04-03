package Mynch::Wallscreen;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;

sub log_page {
    my $self = shift;

    $self->log_data;
    $self->render;
}

sub log_data {
    my $self = shift;
    my $ls   = Mynch::Livestatus->new;

    my $since = time() - 600;    # 10 minutes of log data

    my @columns = qw{ type time state state_type host_name
      service_description attempt
      current_service_max_check_attempts };

    my $query;
    $query .= "GET log\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: time >= $since\n";
    $query .= "Filter: type = SERVICE ALERT\n";

    my $results_ref = $ls->fetch( $query );

    my $data_ref = $ls->massage( $results_ref, \@columns );

    $self->stash( log_content => $data_ref );
}

sub status_data {
    my $self = shift;
    my $ls   = Mynch::Livestatus->new;

    my @columns = qw{ host_groups host_name display_name state
           state_type acknowledged downtimes last_state_change
           last_hard_state_change last_check next_check
           last_notification current_attempt max_check_attempts
           plugin_output };

    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: state != 0\n";

    my $results_ref = $ls->fetch( $query );

    my $status_ref = $ls->massage($results_ref, \@columns);

    $self->stash( services => $status_ref );
}

sub hostgroup_status_data {
    my $self = shift;
    my $ls = Mynch::Livestatus->new;

    my @columns = qw { members members_with_state name num_hosts
                       num_hosts_down num_hosts_pending
                       num_hosts_unreach num_hosts_up num_services
                       num_services_crit num_services_hard_crit
                       num_services_hard_ok num_services_hard_unknown
                       num_services_hard_warn num_services_ok
                       num_services_pending num_services_unknown
                       num_services_warn worst_host_state
                       worst_service_hard_state worst_service_state };

    my $query;
    $query .= "GET hostgroups\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: worst_service_state != 0\n";
    $query .= "Filter: worst_host_state != 0\n";
    $query .= "Or: 2\n";

    my $results_ref = $ls->fetch( $query );
    my $hostgroup_status_ref = $ls->massage($results_ref, \@columns);
    $self->stash( hostgroups => $hostgroup_status_ref );

}

sub hostgroup_status_page {
    my $self = shift;

    $self->hostgroup_status_data;
    $self->render;
}

sub status_page {
    my $self = shift;

    $self->status_data;
    $self->render;
}

sub main_page {
    my $self = shift;

    $self->status_data;
    $self->log_data;
    $self->render;
}

1;
