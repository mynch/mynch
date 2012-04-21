package Mynch::Wallscreen;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use List::MoreUtils qw{ uniq };
use Method::Signatures;

method log_page {
    $self->log_data;
    $self->render;
}

method log_data {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

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

    $self->stash( log_entries => $data_ref );
}

method status_data {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_groups host_name display_name state
           state_type acknowledged downtimes last_state_change
           last_hard_state_change last_check next_check
           last_notification current_attempt max_check_attempts
           plugin_output };

    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: state != 0\n";
    $query .= "Filter: plugin_output != UNKNOWN: No current data from munin\n";
    $query .= "Filter: display_name != Puppet last update\n";
    $query .= "Filter: display_name != Puppet pending\n";
    $query .= "Filter: display_name != Puppet Pending\n";
    $query .= "Filter: display_name != Puppet\n";
    $query .= "Filter: display_name != Pending updates\n";
    $query .= "Filter: display_name != Pending OS Updates\n";
    $query .= "Filter: display_name != apt updates\n";
    $query .= "Filter: display_name != pending packages\n";
    $query .= "Filter: display_name != Pending packages\n";
    $query .= "Filter: display_name != check apt\n";
    $query .= "Filter: display_name != Yum\n";

    my $results_ref = $ls->fetch( $query );

    my $status_ref = $ls->massage($results_ref, \@columns);

    $self->stash( services => $status_ref );
}

method hostgroup_summary {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw { name num_hosts_down num_hosts_unreach
                       num_services_hard_crit num_services_crit
                       num_services_hard_warn num_services_warn };

    my $query;
    $query .= "GET hostgroups\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: hostgroup_name != x-old-nagios\n";
    $query .= "Filter: num_services_crit > 0\n";
    $query .= "Filter: num_hosts_down > 0\n";
    $query .= "Or: 2\n";

    my $results_ref = $ls->fetch( $query );
    my $hostgroup_status_ref = $ls->massage($results_ref, \@columns);
    $self->stash( hostgroups => $hostgroup_status_ref );

}

method hostgroup_status_page {
    $self->hostgroup_summary;
    $self->render;
}

method status_page {
    $self->status_data;
    $self->render;
}

method main_page {
    $self->status_data;
    $self->log_data;
    $self->hostgroup_summary;
    $self->render;
}

1;
