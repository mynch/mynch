package Mynch::Settings;
use Mojo::Base 'Mojolicious::Controller';

sub settings_page {
    my $self = shift;

    $self->stash( settings => $self->session->{settings} );
    $self->render;
}

1;
