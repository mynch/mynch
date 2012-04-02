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
            my $duration;

            if ($time > 0) {
                $duration = concise( duration( time() - $time ) );
            }

            return $duration;
        }
    );

    $app->helper (
        field_title => sub {
            my $self = shift;
            my $field = shift;

            my $fields = {
                display_name           => 'service', # ambiguous
                host_display_name      => 'host',
                host_groups            => 'hostgroup',
                host_name              => 'host',
                last_check             => 'last check',
                last_hard_state_change => 'duration',
                next_check             => 'next check',
                plugin_output          => 'output',
                state                  => 'state',
            };

            return $fields->{$field};
        }
    );

    $app->helper (
        button_recheck => sub {
            my $self = shift;
            my $state = shift;

            my $html = '<button class="btn-mini" type ="submit"><i class="icon-repeat"></i></button>';
            return $html;
        }
    );

    $app->helper (
        button_acknowledge => sub {
            my $self = shift;
            my $state = shift;

            my $html = '<button class="btn-mini" type ="submit"><i class="icon-ok"></i></button>';
            return $html;
        }
    );

    $app->helper (
        format_state => sub {
            my $self = shift;
            my $state = shift;

            my $states = {
                0 => { text => 'ok',        label => 'label-success' },
                1 => { text => 'warning',   label => 'label-warning' },
                2 => { text => 'critical',  label => 'label-important' },
                3 => { text => 'unknown',   label => 'label-info' },
                4 => { text => 'dependent', label => 'label-info' },
            };
            my $html = sprintf('<span class="label %s">%s</span>',
                               $states->{$state}->{label},
                               $states->{$state}->{text});

            return $html;
        }
    );
}

1;
