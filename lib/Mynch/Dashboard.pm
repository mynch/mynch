package Mynch::Dashboard;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
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
    $query .= "Filter: display_name != Package updates\n";
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

    my $results_ref = $ls->fetch( $query );
    my $hostgroup_status_ref = $ls->massage($results_ref, \@columns);
    $self->stash( hostgroups => $hostgroup_status_ref );

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

    $self->redirect_to($referrer);
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
