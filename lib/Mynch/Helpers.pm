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

            my $fields = {
                host_groups => 'hostgroup',
                host_display_name => 'host',
                display_name => 'service',
                state => 'state',
                plugin_output => 'output',
            };

            return $fields->{$field};
        }
    );

    $app->helper (
        get_hostgroup_buttons => sub {
            my $self = shift;
            my $buttons;

            return $buttons;

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

            if ( $state ne '0' ) {
                $html .= ' <button class="btn-mini" type ="submit"><i class="icon-repeat"></i></button> ';
                $html .= ' <button class="btn-mini" type ="submit"><i class="icon-ok"></i></button> ';
            }
            return $html;
        }
    );
}

1;
