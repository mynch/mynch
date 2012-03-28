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

    $app->helper (
        field_title => sub {
            my $self = shift;
            my $field = shift;

            ...;

            my $fields = {
                host_groups => 'hostgroup',
                display_name => 'name',
            };

            return $fields->{$field};
        }
    );

    $app->helper (
        get_hostgroup_buttons => sub {
            my $self = shift;
            my $hostgroup = shift; # Get from object instead?

            my $buttons;

            ...;

            return $buttons;

        }
    );
}

1;
