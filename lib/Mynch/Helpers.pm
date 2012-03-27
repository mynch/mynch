package Mynch::Helpers;

use Time::Duration;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

sub register {
    my ( $self, $app ) = @_;

    $app->helper(
        duration => sub {
            my $self = shift;
            my $time = shift;
            return concise( duration( time() - $time ) );
        }
    );

}

1;
