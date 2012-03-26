package Mynch::Json;
use Mojo::Base 'Mojolicious::Controller';
use Mynch::Livestatus;

sub raw {
    my $self = shift;

    my $livestatus = Mynch::Livestatus->content();
    $self->render(
        json => $livestatus,
    );
}

sub servicesbyhostgroup {
    my $self = shift;
    my $livestatus = Mynch::Livestatus->servicesbyhostgroup;
    $self->render(json => $livestatus);
}

1;
