package Mynch::Settings;
use Mojo::Base 'Mojolicious::Controller';

sub settings_page {
    my $self = shift;

    $self->stash( settings => $self->session->{settings} );
    $self->render;
}

sub edit_page {
    my $self = shift;
    $self->stash ( settings => $self->session->{settings} );
    $self->render;
}

sub verify_settings {
    my $self = shift;

    # TODO: Validate fields

    if ($self->param('label') and $self->param('hostgroups')) {
        $self->session->{settings}->{view} ||= [];
        my $set = {
            label      => $self->param('label'),
            hostgroups => $self->param('hostgroups')
        };
        push ($self->session->{settings}->{view}, $set);
    }

    $self->flash( message => 'Settings have been saved');

    if ($self->param('add')) {
        $self->redirect_to('/settings/edit');
    }
    else {
        $self->redirect_to('/settings');
    }



}

sub clear_settings {
    my $self = shift;

    $self->flash( message => 'settings reverted to default' );
    $self->session( expires => 1);
    $self->redirect_to('/settings');

}
1;
