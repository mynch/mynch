package Mynch::Dashboard;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use Mynch::Config;
use List::MoreUtils qw{ uniq };
use Method::Signatures;

method log {
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
    $query .= $self->hostgroup_filter(query_key => 'current_host_groups', query_operator => '>=');

    my $results_ref = $ls->fetch( $query );

    my $data_ref = $ls->massage( $results_ref, \@columns );

    $self->stash( log_entries => $data_ref );
}

method log_data_host {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my $since = time() - 86400;    # 1 day of log data

    my @columns = qw{ type time state state_type host_name
      service_description attempt
      current_service_max_check_attempts };

    my $query;
    $query .= "GET log\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: time >= $since\n";
    $query .= "Filter: host_name = " . $self->stash->{show_host} . "\n";
    $query .= "Filter: type = SERVICE ALERT\n";
    $query .= "Filter: type = HOST ALERT\n";
    $query .= "Or: 2\n";

    my $results_ref = $ls->fetch( $query );

    my $data_ref = $ls->massage( $results_ref, \@columns );

    $self->stash( log_entries => $data_ref );
}


method host_data {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ accept_passive_checks acknowledged acknowledgement_type action_url action_url_expanded active_checks_enabled address alias check_command check_flapping_recovery_notification check_freshness check_interval check_options check_period check_type checks_enabled childs comments comments_with_info contact_groups contacts current_attempt current_notification_number custom_variable_names custom_variable_values custom_variables display_name downtimes downtimes_with_info event_handler event_handler_enabled execution_time filename first_notification_delay flap_detection_enabled groups hard_state has_been_checked high_flap_threshold icon_image icon_image_alt icon_image_expanded in_check_period in_notification_period initial_state is_executing is_flapping last_check last_hard_state last_hard_state_change last_notification last_state last_state_change last_time_down last_time_unreachable last_time_up latency long_plugin_output low_flap_threshold max_check_attempts modified_attributes modified_attributes_list name next_check next_notification no_more_notifications notes notes_expanded notes_url notes_url_expanded notification_interval notification_period notifications_enabled num_services num_services_crit num_services_hard_crit num_services_hard_ok num_services_hard_unknown num_services_hard_warn num_services_ok num_services_pending num_services_unknown num_services_warn obsess_over_host parents pending_flex_downtime percent_state_change perf_data plugin_output pnpgraph_present process_performance_data retry_interval scheduled_downtime_depth state state_type statusmap_image total_services worst_service_hard_state worst_service_state };

    my $query;
    $query .= "GET hosts\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: name =~ " . $self->stash->{show_host} . "\n";
    my $results_ref = $ls->fetch( $query );

    my $tmp_status_ref = $ls->massage($results_ref, \@columns);
 
   $self->stash( host => $tmp_status_ref );
}

method host_downtime_data {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ author comment end_time start_time is_service service_display_name };

    my $query;
    $query .= "GET downtimes\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: host_name =~ " . $self->stash->{show_host} . "\n";
    my $results_ref = $ls->fetch( $query );

    my $tmp_status_ref = $ls->massage($results_ref, \@columns);
 
   $self->stash( downtimes => $tmp_status_ref );
}

method host_service_data {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_name display_name state
           state_type acknowledged downtimes last_state_change
           last_hard_state_change last_check next_check
           last_notification current_attempt max_check_attempts
           plugin_output long_plugin_output };

    my $query;
    $query .= "GET services\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: host_name =~ " . $self->stash->{show_host} . "\n";
    my $results_ref = $ls->fetch( $query );

    my $tmp_status_ref = $ls->massage($results_ref, \@columns);
 
   $self->stash( host_services => $tmp_status_ref );
}

method status_data {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ host_groups host_name display_name state
           state_type acknowledged downtimes last_state_change
           last_hard_state_change last_check next_check
           last_notification current_attempt max_check_attempts
           plugin_output long_plugin_output };

    my $query;
    $query .= "GET servicesbyhostgroup\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: state != 0\n";
    $query .= Mynch::Config->build_filter($self->stash->{config}, "service-noise");
    $query .= $self->hostgroup_filter(query_key => 'host_groups', query_operator => '>=');
    my $results_ref = $ls->fetch( $query );

    my $tmp_status_ref = $ls->massage($results_ref, \@columns);
    my @status = ();

    # Remove duplicates
    my %seen = ();
    for my $services ( @{ $tmp_status_ref }) {
      my $key = $services->{ 'host_name' } . $services->{ 'display_name' };
      if ( ! $seen{ $key }) {
        push @status, $services;
       $seen{ $key } = 1;
      }
    }

    $self->stash( services => \@status );
}

method hostgroup_summary {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw { name num_hosts_down num_hosts_unreach
                       num_services_hard_crit num_services_crit
                       num_services_hard_warn num_services_warn };

    my $query;
    $query .= "GET hostgroups\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: num_services_crit > 0\n";
    $query .= "Filter: num_hosts_down > 0\n";
    $query .= "Or: 2\n";
    if (exists $self->stash->{show_hostgroups}) {
        $query .= $self->hostgroup_filter(query_key => 'name', query_operator => '=');
        $query .= "And: 2\n";
    }
    if (exists $self->stash->{config}->{filters}->{'hide-hostgroups'})
    {
        foreach my $hidegroup (@{ $self->stash->{config}->{filters}->{'hide-hostgroups'} })
        {
          $query .= "Filter: name != $hidegroup\n";
        }
    }

    my $results_ref = $ls->fetch( $query );
    my $hostgroup_status_ref = $ls->massage($results_ref, \@columns);
    $self->stash( hostgroups => $hostgroup_status_ref );

}

method hostgroup_context {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw{ accept_passive_checks acknowledged acknowledgement_type action_url action_url_expanded active_checks_enabled address alias check_command check_flapping_recovery_notification check_freshness check_interval check_options check_period check_type checks_enabled childs comments comments_with_info contact_groups contacts current_attempt current_notification_number custom_variable_names custom_variable_values custom_variables display_name downtimes downtimes_with_info event_handler event_handler_enabled execution_time filename first_notification_delay flap_detection_enabled groups hard_state has_been_checked high_flap_threshold icon_image icon_image_alt icon_image_expanded in_check_period in_notification_period initial_state is_executing is_flapping last_check last_hard_state last_hard_state_change last_notification last_state last_state_change last_time_down last_time_unreachable last_time_up latency long_plugin_output low_flap_threshold max_check_attempts modified_attributes modified_attributes_list name next_check next_notification no_more_notifications notes notes_expanded notes_url notes_url_expanded notification_interval notification_period notifications_enabled num_services num_services_crit num_services_hard_crit num_services_hard_ok num_services_hard_unknown num_services_hard_warn num_services_ok num_services_pending num_services_unknown num_services_warn obsess_over_host parents pending_flex_downtime percent_state_change perf_data plugin_output pnpgraph_present process_performance_data retry_interval scheduled_downtime_depth state state_type statusmap_image total_services worst_service_hard_state worst_service_state };

    my $entry = @{ $self->stash->{host} }[0];
    if (scalar @{ $entry->{groups} } > 0)
    {
      foreach my $hostgroup (@{ $entry->{groups} }) {
        my $query;
        $query .= "GET hosts\n";
        $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
        $query .= "Filter: groups >= $hostgroup";

        my $results_ref = $ls->fetch( $query );
        my $hostgroup_context_ref = $ls->massage($results_ref, \@columns);
        $self->stash( "hostgroup_$hostgroup" => $hostgroup_context_ref );
      }
    }
}

sub dostuff {
    my $self = shift;

    my $host       = $self->param('host');
    my $service    = $self->param('service');
    my $submit     = $self->param('submit');
    my $referrer   = $self->req->headers->referrer;

    my $notify     = 1; # FIXME: adjustable
    my $nick       = $ENV{'REMOTE_USER'} || "vaktsmurfen";

    my $now        = time();

    if ($host && $service && $submit) {
      my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );
      if ($submit eq "Ack") {
        $ls->send_commands("ACKNOWLEDGE_SVC_PROBLEM;$host;$service;1;$notify;1;$nick;Ack.");
      }
      elsif ($submit eq "Recheck") {
        $ls->send_commands("SCHEDULE_FORCED_SVC_CHECK;$host;$service;$now");
      }
    }

    if ($host && $submit) {
      my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );
      if ($submit eq "Ack") {
        $ls->send_commands("ACKNOWLEDGE_HOST_PROBLEM;$host;1;$notify;1;$nick;Ack.");
      }
      if ($submit eq "Recheck") {
        $ls->send_commands("SCHEDULE_FORCED_HOST_CHECK;$host;$now");
      }
      if ($submit eq "RecheckAll") {
        $ls->send_commands("SCHEDULE_FORCED_HOST_CHECK;$host;$now\n"
                          ."SCHEDULE_FORCED_HOST_SVC_CHECKS;$host;$now");
      }
    }

    $self->redirect_to($referrer);
}

method host {
    $self->host_data;
    $self->host_service_data;
    $self->host_downtime_data;
    $self->log_data_host;
    $self->hostgroup_context;
    $self->render;
}

method hostgroups {
    $self->hostgroup_summary;
    $self->render;
}

method status {
    $self->status_data;
    $self->render;
}

method main_page {
    $self->status_data;
    $self->log_data;
    $self->hostgroup_summary;
    $self->render;
}

method hostgroup_filter(Str :$query_key, Str :$query_operator) {
    my $query = '';
    if (exists $self->stash->{show_hostgroups}) {
        my @hostgroups = split(/,/, $self->stash->{show_hostgroups});
        foreach my $hostgroup (@hostgroups) {
            $query .= sprintf("Filter: %s %s %s\n", $query_key, $query_operator, $hostgroup);
        }
        if (scalar @hostgroups > 1) {
            $query .= sprintf("Or: %d\n", scalar @hostgroups);
        }
    }
    return $query;
}
1;
