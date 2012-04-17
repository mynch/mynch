package Mynch::Settings;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;

sub settings_page {
    my $self = shift;

    $self->stash( settings => $self->session->{settings} );
    $self->render;
}

sub edit_page {
    my $self = shift;

    $self->stash( settings => $self->session->{settings} );
    $self->render;
}

sub add_set {
    my $self = shift;
    $self->session->{settings}->{view} ||= [];

    if ( $self->param('label') and $self->param('hostgroups') ) {
        $self->session->{settings}->{view} ||= [];
        my $set = {
            label      => $self->param('label'),
            hostgroups => $self->param('hostgroups')
        };
        push( $self->session->{settings}->{view}, $set );
    }

    $self->redirect_to('/settings/edit');
}

sub save_set {
    my $self = shift;

    my $set        = $self->param('set');
    my $label      = $self->param('label');
    my $hostgroups = $self->param('hostgroups');

    $self->session->{settings}->{view} ||= [];

    my $set_data = {
        label      => $self->param('label'),
        hostgroups => $self->param('hostgroups')
    };

    $self->session->{settings}->{view}->[$set] = $set_data;

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

sub clear_settings {
    my $self = shift;

    $self->flash( message => 'settings reverted to default' );
    $self->session( expires => 1 );
    $self->redirect_to('/settings');

}

1;
