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

            if ( $time > 0 ) {
                $duration = concise( duration( time() - $time ) );
            }

            return $duration;
        }
    );

    $app->helper(
        field_title => sub {
            my $self  = shift;
            my $field = shift;

            my $fields = {
                display_name           => 'service',      # ambiguous
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

    $app->helper(
        hostgroup_background => sub {
            my $self      = shift;
            my $hostgroup = shift;

            my $backgrounds = {
                up       => 'alert alert-success',
                down     => 'alert alert-error',
                ok       => 'alert alert-success',
                warning  => 'alert',
                critical => 'alert alert-error',
                unknown  => 'alert alert-info',
            };

            my $host_states = {
                0 => 'up',
                1 => 'up',
                2 => 'down',
                3 => 'down',
            };

            my $service_states = {
                0 => 'ok',
                1 => 'warning',
                2 => 'critical',
                3 => 'unknown',
            };

            if ($host_states->{$hostgroup->{worst_host_state}} ne 'up' ) {
                return $backgrounds->{$host_states->{$hostgroup->{worst_host_state}}};
            }
            else {
                return $backgrounds->{$service_states->{$hostgroup->{worst_service_state}}};
            }
        }
    );

    $app->helper(
        hostgroup_sort => sub {
            my $self           = shift;
            my $hostgroups_ref = shift;

            my @hostgroups = @{ $hostgroups_ref };

            my $service_weight = {
                0 => 4,
                1 => 1,
                2 => 0,
                3 => 2,
                4 => 3,
            };
            my $host_weight = {
                0 => 4,
                1 => 4,
                2 => 0,
                3 => 0,
            };

            my @sorted = sort {
                $host_weight->{$a->{worst_host_state}} <=> $host_weight->{$b->{worst_host_state}}
                    ||
                $service_weight->{$a->{worst_service_state}} <=> $service_weight->{$b->{worst_service_state}}
            } @hostgroups;

            return @sorted;
        }
    );

    $app->helper(
        servicesbyhostgroup_sort => sub {
            my $self         = shift;
            my $services_ref = shift;

            my @services = @{ $services_ref };

            my $weight = {
                0 => 4,
                1 => 1,
                2 => 0,
                3 => 2,
                4 => 3,
            };

            my @sorted = sort {
                $weight->{$a->{state}} <=> $weight->{$b->{state}} ||
                    $a->{last_state_change} <=> $b->{last_state_change}
                } @services;

            return @sorted;
        }
    );

    $app->helper(
        button_recheck => sub {
            my $self  = shift;
            my $state = shift;

            my $html =
'<button class="btn-mini" type ="submit"><i class="icon-repeat"></i></button>';
            return $html;
        }
    );

    $app->helper(
        button_acknowledge => sub {
            my $self  = shift;
            my $state = shift;

            my $html =
'<button class="btn-mini" type ="submit"><i class="icon-ok"></i></button>';
            return $html;
        }
    );

    $app->helper(
        format_state => sub {
            my $self  = shift;
            my $state = shift;

            my $states = {
                0 => { text => 'ok',        label => 'label-success' },
                1 => { text => 'warning',   label => 'label-warning' },
                2 => { text => 'critical',  label => 'label-important' },
                3 => { text => 'unknown',   label => 'label-info' },
                4 => { text => 'dependent', label => 'label-info' },
            };
            my $html = sprintf(
                '<span class="label %s">%s</span>',
                $states->{$state}->{label},
                $states->{$state}->{text}
            );

            return $html;
        }
    );

    $app->helper(
        service_state_label => sub {
            my $self       = shift;
            my $attributes = shift;

            my $states = {
                0 => {
                    text  => 'ok',
                    label => {
                        HARD => 'label-success',
                        SOFT => 'label',
                    },
                },
                1 => {
                    text  => 'warning',
                    label => {
                        HARD => 'label-warning',
                        SOFT => 'label',
                    },
                },
                2 => {
                    text  => 'critical',
                    label => {
                        HARD => 'label-important',
                        SOFT => 'label',
                    },
                },
                3 => {
                    text  => 'unknown',
                    label => {
                        HARD => 'label-info',
                        SOFT => 'label',
                    },
                },
                4 => {
                    text  => 'dependent',
                    label => {
                        HARD => 'label-info',
                        SOFT => 'label',
                    },
                },
            };

            # Unwrap, for readability
            my $state_type   = $attributes->{state_type};
            my $state        = $attributes->{state};
            my $attempt      = $attributes->{attempt};
            my $max_attempts = $attributes->{max_attempts};

            # Rewrite state_type, if "0" or "1" (from "GET servicesbyhostgroup")
            if    ($state_type eq "0") { $state_type = "SOFT"; }
            elsif ($state_type eq "1") { $state_type = "HARD"; }

            # Button content
            my $label = $states->{$state}->{label}->{$state_type};
            my $text  = $states->{$state}->{text};

            # Extra text for SOFT non-OK entries
            if ( $state_type eq "SOFT" and $state ne '0' ) {
                $text .= sprintf( "&nbsp;(%d/%d)",
                                  $attempt, $max_attempts, );
            }

            my $html =
              sprintf( '<span class="label %s">%s</span>', $label, $text );


            return $html;
        }
    );

}

1;
