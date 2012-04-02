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

    $app->helper (
        format_state_log => sub {
            my $self = shift;
            my $logentry = shift;

            my $states = {
                0 => { text => 'ok',
                       label => { HARD => 'label-success',
                                  SOFT => 'label', }, },
                1 => { text => 'warning',
                       label => { HARD => 'label-warning',
                                  SOFT => 'label', }, },
                2 => { text => 'critical',
                       label => { HARD => 'label-important',
                                  SOFT => 'label', }, },
                3 => { text => 'unknown',
                       label => { HARD => 'label-info',
                                  SOFT => 'label', }, },
                4 => { text => 'dependent',
                       label => { HARD => 'label-info',
                                  SOFT => 'label', }, },
            };

            # Unwrap, for readability
            my $state_type         = $logentry->{state_type};
            my $state              = $logentry->{state};
            my $current_attempt    = $logentry->{current_service_current_attempt};
            my $max_check_attempts = $logentry->{current_service_max_check_attempts};

            # Button content
            my $label              = $states->{$state}->{label}->{$state_type};
            my $text               = $states->{$state}->{text};

            my $html = sprintf('<span class="label %s">%s</span>', $label, $text);

            # Extra text for SOFT log entries
            if ($logentry->{state_type} eq "SOFT") {
                $html .= sprintf("&nbsp;(%d/%d)", $current_attempt, $max_check_attempts, );
            }

            return $html;
        }
    );

}

1;
