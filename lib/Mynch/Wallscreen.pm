# Copyright: 2012 Erik Inge Bolsø <knan@redpill-linpro.com>
# Copyright: 2012 Lars Olavsen <larso@redpill-linpro.com>
# Copyright: 2012 Stig Sandbeck Mathisen <ssm@redpill-linpro.com>

# This file is part of Mynch.
#
# Mynch is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Mynch is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mynch.  If not, see <http://www.gnu.org/licenses/>.

package Mynch::Wallscreen;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use Mynch::Config;
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
    $query .= $self->hostgroup_filter(
        query_key      => 'current_host_groups',
        query_operator => '>='
    );

    my $results_ref = $ls->fetch($query);

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
    $query .= Mynch::Config->build_filter( $self->stash->{config},
        "service-noise" );
    $query .= $self->hostgroup_filter(
        query_key      => 'host_groups',
        query_operator => '>='
    );
    my $results_ref = $ls->fetch($query);

    my $tmp_status_ref = $ls->massage( $results_ref, \@columns );
    my @status = ();

    # Remove duplicates
    my %seen = ();
    for my $services ( @{$tmp_status_ref} ) {
        my $key = $services->{'host_name'} . $services->{'display_name'};
        if ( !$seen{$key} ) {
            push @status, $services;
            $seen{$key} = 1;
        }
    }

    $self->stash( services => \@status );
}

method hostgroup_summary {
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my @columns = qw { name num_hosts_down num_hosts_unreach
        num_services_hard_unknown num_services_unknown
        num_services_hard_crit num_services_crit
        num_services_hard_warn num_services_warn };

    my $query;
    $query .= "GET hostgroups\n";
    $query .= sprintf( "Columns: %s\n", join( " ", @columns ) );
    $query .= "Filter: num_services_unknown > 0\n";
    $query .= "Filter: num_services_warn > 0\n";
    $query .= "Filter: num_services_crit > 0\n";
    $query .= "Filter: num_hosts_down > 0\n";
    $query .= "Filter: num_hosts_unreach > 0\n";
    $query .= "Or: 5\n";
    $query .= $self->hostgroup_filter(
        query_key      => 'name',
        query_operator => '='
    );

    if ( exists $self->stash->{config}->{filters}->{'hide-hostgroups'} ) {

        foreach my $hidegroup (
            @{ $self->stash->{config}->{filters}->{'hide-hostgroups'} } )
        {
            $query .= "Filter: name != $hidegroup\n";
        }
    }

    my $results_ref = $ls->fetch($query);
    my $hostgroup_status_ref = $ls->massage( $results_ref, \@columns );
    $self->stash( hostgroups => $hostgroup_status_ref );

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
    my @hostgroups;
    if ( exists $self->stash->{show_hostgroups} ) {
        @hostgroups = split( /,/, $self->stash->{show_hostgroups} );
    }
    elsif ( exists $self->session->{settings} ) {
        my $settings = $self->session->{settings};
        my @views    = $settings->{view};
        foreach my $hashref ( @{ $views[0] } ) {
            push @hostgroups, @{ $hashref->{hostgroups} };
        }
    }

    foreach my $hostgroup (@hostgroups) {
        $query .= sprintf( "Filter: %s %s %s\n",
            $query_key, $query_operator, $hostgroup );
    }
    if ( scalar @hostgroups > 1 ) {
        $query .= sprintf( "Or: %d\n", scalar @hostgroups );
    }

    return $query;
}
1;
