package Mynch::Settings;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;
use Quantum::Superpositions;
use Method::Signatures;

sub settings_page {
    my $self = shift;

    $self->stash( settings => $self->session->{settings} );
    $self->render;
}

sub edit {
    my $self = shift;

    $self->stash( settings => $self->session->{settings} );
    $self->render;
}

sub save_set {
    my $self = shift;

    my $set        = $self->param('set');
    my $label      = $self->param('label');
    my $hostgroups = $self->param('hostgroups');

    my $hostgroups_ref = $self->wash_hostgroups($hostgroups);

    if ( $label and scalar @{ $hostgroups_ref } ) {
        my $set_data = {
            label      => $label,
            hostgroups => $hostgroups_ref
        };

	$self->session->{settings}->{view} ||= [];

        if ($set eq 'new') {
            push( @{ $self->session->{settings}->{view} }, $set_data );
            $self->flash( message => 'Added set' );
        }
        else {
            $self->session->{settings}->{view}->[$set] = $set_data;
            $self->flash( message => 'Updated set' );
        }
    }
    else {
        $self->flash( message => 'No set changed. No label, or no hostgroups (after washing)');
    }

    $self->redirect_to('/settings/edit');
}

sub delete_set {
    my $self = shift;

    my $set = $self->param('set');

    my $length = 1;    # Used for splicing

    if ( not $set =~ /^\d+$/ ) {
        $self->flash( message => 'Got junk data' );
    }
    elsif (
        not(   $set >= 0
            && $set < scalar @{ $self->session->{settings}->{view} } )
        )
    {
        $self->flash( message => 'Already deleted' );
    }
    else {
        splice( @{ $self->session->{settings}->{view} }, $set, $length );
        $self->flash( message => 'Deleted set' );
    }

    $self->redirect_to('/settings/edit');

}

sub clear {
    my $self = shift;

    $self->flash( message => 'settings reverted to default' );
    $self->session( expires => 1 );
    $self->redirect_to('/settings');

}

sub wash_hostgroups {
    my $self = shift;
    my $hostgroups = shift;

    my @candidate_hostgroups = split(/[,\s]+/, $hostgroups);

    my $live_hostgroups_ref = $self->list_hostgroups();
    my @live_hostgroups = @{ $live_hostgroups_ref };

    my @ok_hostgroups = eigenstates ( all ( any(@candidate_hostgroups),
                                            any(@live_hostgroups)
                                        )
                                  );

    return \@ok_hostgroups;
}

sub list_hostgroups {
    my $self = shift;
    my $ls = Mynch::Livestatus->new( config => $self->stash->{config}->{ml} );

    my $query;
    $query .= "GET hostgroups\n";
    $query .= "Columns: name\n";

    my $results_ref = $ls->fetch( $query );

    my @hostgroups = map { $_->[0] } @{ $results_ref };

    return \@hostgroups;
}
1;
