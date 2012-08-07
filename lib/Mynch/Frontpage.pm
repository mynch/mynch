package Mynch::Frontpage;
use Mojo::Base 'Mojolicious::Controller';
use Method::Signatures;

method frontpage {
    $self->render;
}
1;
