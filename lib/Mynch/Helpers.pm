# Copyright: 2012 Erik Inge Bolsø <knan@redpill-linpro.com>
# Copyright: 2012 Stig Sandbeck Mathisen <ssm@redpill-linpro.com>

# This file is part of Mynch.
#
# Mynch is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Mynch is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mynch.  If not, see <http://www.gnu.org/licenses/>.

package Mynch::Helpers;

use Time::Duration;
use Date::Format;
use Digest::SHA qw(sha1_hex);
use URI::Escape;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

sub register {
    my ( $self, $app ) = @_;

    $app->helper(
        abbr_datetime => sub {
            my $self = shift;
            my $time = shift;

            return time2str( "%h %d %R", $time );
        }
    );

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

            if ( $host_states->{ $hostgroup->{worst_host_state} } ne 'up' ) {
                return
                    $backgrounds
                    ->{ $host_states->{ $hostgroup->{worst_host_state} } };
            }
            else {
                return
                    $backgrounds->{ $service_states
                        ->{ $hostgroup->{worst_service_state} } };
            }
        }
    );

    $app->helper(
        hostgroup_sort => sub {
            my $self           = shift;
            my $hostgroups_ref = shift;

            my @hostgroups = @{$hostgroups_ref};

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
                       $b->{num_hosts_down} <=> $a->{num_hosts_down}
                    || $b->{num_services_crit} <=> $a->{num_services_crit}
                    || $b->{num_services_warn} <=> $a->{num_services_warn}
            } @hostgroups;

            return @sorted;
        }
    );

    $app->helper(
        servicesbyhostgroup_sort => sub {
            my $self         = shift;
            my $services_ref = shift;

            my @services = @{$services_ref};

            my $weight = {
                0 => 4,
                1 => 1,
                2 => 0,
                3 => 2,
                4 => 3,
            };

            my @sorted = sort {
                       $weight->{ $a->{state} } <=> $weight->{ $b->{state} }
                    || $a->{last_state_change} <=> $b->{last_state_change}
            } @services;

            return @sorted;
        }
    );

    $app->helper(
        button_downtime => sub {
            my $self = shift;

            my $html
                = '<button class="btn btn-primary" '
                . 'onClick="$(\'#downtimemodal\').modal(\'show\');" '
                . 'type="button"><i class="icon-wrench"></i> Schedule downtime</button>';
            return $html;
        }
    );

    $app->helper(
        button_comment => sub {
            my $self = shift;

            my $html
                = '<button class="btn btn-primary" '
                . 'onClick="$(\'#commentmodal\').modal(\'show\');" '
                . 'type="button"><i class="icon-comment"></i> Add comment</button>';
            return $html;
        }
    );

    $app->helper(
        button_recheck => sub {
            my $self    = shift;
            my $host    = shift;
            my $service = shift;
            my $id      = sha1_hex( $host . $service . "Recheck" );

            my $html
                = '<button class="btn btn-mini" data-loading-text="rechecking..." id="'
                . $id . '" '
                . 'onClick=\'doajax( { host: "'
                . $host
                . '", service: "'
                . $service
                . '", submit: "Recheck", id: "'
                . $id
                . '" } );\' '
                . 'type="submit" name="submit" value="Recheck" alt="Recheck" title="Recheck"><i alt="Recheck" title="Recheck" class="icon-refresh"></i></button>';
            return $html;
        }
    );

    $app->helper(
        button_recheck_host => sub {
            my $self = shift;
            my $host = shift;
            my $id   = sha1_hex( $host . "Recheck" );

            my $html
                = '<button class="btn btn-mini" data-loading-text="rechecking..." id="'
                . $id . '" '
                . 'onClick=\'doajax( { host: "'
                . $host
                . '", submit: "Recheck", id: "'
                . $id
                . '" } );\' '
                . 'type="submit" name="submit" value="Recheck" alt="Recheck" title="Recheck"><i alt="Recheck" title="Recheck" class="icon-refresh"></i></button>';
            return $html;
        }
    );

    $app->helper(
        button_recheck_all => sub {
            my $self    = shift;
            my $host    = shift;
            my $service = shift;
            my $id      = sha1_hex( $host . "RecheckAll" );

            my $html
                = '<button class="btn btn-primary" data-loading-text="rechecking..." id="'
                . $id . '" '
                . 'onClick=\'doajax( { host: "'
                . $host
                . '", submit: "RecheckAll", id: "'
                . $id
                . '" } );\' '
                . 'type="submit" name="submit" value="RecheckAll" alt="Recheck" title="Recheck"><i alt="Recheck All" title="Recheck All" class="icon-refresh"></i> Recheck all</button>';
            return $html;
        }
    );

    $app->helper(
        button_acknowledge => sub {
            my $self         = shift;
            my $host         = shift;
            my $service      = shift;
            my $acknowledged = shift;
            my $class        = "btn btn-mini";
            my $id           = sha1_hex( $host . $service . "Ack" );
            my $html         = "";

            if ( $acknowledged == 1 ) {
                $class .= " btn-success";

                $html
                    = '<button class="'
                    . $class
                    . '" data-loading-text="unacking..." id="'
                    . $id . '" '
                    . 'onClick=\'doajax( { host: "'
                    . $host
                    . '", service: "'
                    . $service
                    . '", submit: "UnAck", id: "'
                    . $id
                    . '" } );\' '
                    . 'type="submit" name="submit" value="UnAck" alt="Unack" title="UnAck"><i alt="UnAck" title="UnAck" class="icon-ok"></i></button>';
            }
            else {
                $html
                    = '<button class="'
                    . $class
                    . '" data-loading-text="acking..." id="'
                    . $id . '" '
                    . 'onClick=\'doajax( { host: "'
                    . $host
                    . '", service: "'
                    . $service
                    . '", submit: "Ack", id: "'
                    . $id
                    . '" } );\' '
                    . 'type="submit" name="submit" value="Ack" alt="Ack" title="Ack"><i alt="Ack" title="Ack" class="icon-ok"></i></button>';
            }
            return $html;
        }
    );

    $app->helper(
        button_acknowledge_host => sub {
            my $self         = shift;
            my $host         = shift;
            my $acknowledged = shift;
            my $class        = "btn btn-mini";
            my $id           = sha1_hex( $host . "Ack" );
            my $html         = "";

            if ( $acknowledged == 1 ) {
                $class .= " btn-success";

                $html
                    = '<button class="'
                    . $class
                    . '" data-loading-text="unacking..." id="'
                    . $id . '" '
                    . 'onClick=\'doajax( { host: "'
                    . $host
                    . '", submit: "UnAck", id: "'
                    . $id
                    . '" } );\' '
                    . 'type="submit" name="submit" value="UnAck" alt="UnAck" title="UnAck"><i alt="UnAck" title="UnAck" class="icon-ok"></i></button>';
            }
            else {
                $html
                    = '<button class="'
                    . $class
                    . '" data-loading-text="acking..." id="'
                    . $id . '" '
                    . 'onClick=\'doajax( { host: "'
                    . $host
                    . '", submit: "Ack", id: "'
                    . $id
                    . '" } );\' '
                    . 'type="submit" name="submit" value="Ack" alt="Ack" title="Ack"><i alt="Ack" title="Ack" class="icon-ok"></i></button>';
            }
            return $html;
        }
    );

    $app->helper(
        button_delete_comment => sub {
            my $self       = shift;
            my $comment    = shift;
            my $is_service = shift;
            my $id         = sha1_hex( $comment . "DelComment" );

            my $html
                = '<button class="btn btn-mini" id="'
                . $id . '" '
                . 'onClick=\'doajax( { comment: "'
                . $comment
                . '", is_service: "'
                . $is_service
                . '", submit: "DelComment", id: "'
                . $id
                . '" } ); $("#comment'
                . $comment
                . '").remove()\' '
                . 'type="submit" name="submit" value="DelComment" alt="DelComment" title="DelComment"><i alt="DelComment" title="DelComment" class="icon-remove"></i></button>';
            return $html;
        }
    );

    $app->helper(
        link_extinfo => sub {
            my $self 	= shift;
            my $host    = shift;
            my $service = shift;

            my $html;

            if ($service) {
                $html
                = '<li class="span4">'
                . '<a href="' . $self->config->{cgiurl} . 'extinfo.cgi?type=2&'
                . 'host=' . $host
                . '&service=' . uri_escape($service)
                . '">'
                . '<i class="icon-eye-open"></i>' . "\n"
                . 'Nagios/Icinga page</a>'
                . '</li>'
            }
            else
            {
                $html
                = '<li class="span4">'
                . '<a href="' . $self->config->{cgiurl} . 'extinfo.cgi?type=1&'
                . 'host=' . $host . '">'
                . '<i class="icon-eye-open"></i>' . "\n"
                . 'Nagios/Icinga page</a>'
                . '</li>'
            }
            return $html;
        }
    );

    $app->helper(
        link_notesurl => sub {
            my $self 	= shift;
            my $url     = shift;

            return unless $url;

            my $html
                = '<li class="span4">'
                . '<a href="' . $url . '">'
                . '<i class="icon-file"></i>' . "\n"
                . 'Extra Notes</a>'
                . '</li>';

            return $html;
        }
    );

    $app->helper(
        link_actionurl => sub {
            my $self 	= shift;
            my $url     = shift;

            return unless $url;

            my $html
                = '<li class="span4">'
                . '<a href="' . $url . '">'
                . '<i class="icon-cogs"></i>' . "\n"
                . 'Extra Actions</a>'
                . '</li>';

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
            if    ( $state_type eq "0" ) { $state_type = "SOFT"; }
            elsif ( $state_type eq "1" ) { $state_type = "HARD"; }

            # Button content
            my $label = $states->{$state}->{label}->{$state_type};
            my $text  = $states->{$state}->{text};

            # Extra text for SOFT non-OK entries
            if ( $state_type eq "SOFT" and $state ne '0' ) {
                $text .= sprintf( "&nbsp;(%d/%d)", $attempt, $max_attempts, );
            }

            my $html = sprintf( '<span class="label %s">%s</span>', $label,
                $text );

            return $html;
        }
    );

    $app->helper(
        host_state_label => sub {
            my $self       = shift;
            my $attributes = shift;

            my $states = {
                0 => {
                    text  => 'up',
                    label => {
                        HARD => 'label-success',
                        SOFT => 'label',
                    },
                },
                1 => {
                    text  => 'down',
                    label => {
                        HARD => 'label-important',
                        SOFT => 'label',
                    },
                },
                2 => {
                    text  => 'unreachable',
                    label => {
                        HARD => 'label-warning',
                        SOFT => 'label',
                    },
                },
            };

            # Unwrap, for readability
            my $state_type   = $attributes->{state_type};
            my $state        = $attributes->{state};
            my $attempt      = $attributes->{current_attempt} ;
            my $max_attempts = $attributes->{max_check_attempts};

            # Rewrite state_type, if "0" or "1" (from "GET hosts")
            if    ( $state_type eq "0" ) { $state_type = "SOFT"; }
            elsif ( $state_type eq "1" ) { $state_type = "HARD"; }

            # Button content
            my $label = $states->{$state}->{label}->{$state_type};
            my $text  = $states->{$state}->{text};

            # Extra text for SOFT non-UP entries
            if ( $state_type eq "SOFT" and $state ne '0' ) {
                $text .= sprintf( "&nbsp;(%d/%d)", $attempt, $max_attempts, );
            }

            my $html = sprintf( '<span class="label %s">%s</span>', $label,
                $text );

            return $html;
        }
    );
}

1;
