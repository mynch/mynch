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

package Mynch::Config;
use Mojo::Base -base;
use Method::Signatures;
use Contextual::Return;
use List::MoreUtils qw{ any };

method build_filter ( HashRef $config, Str $what_filter ) {
    my $working_filter;

    my @filter = @{ $config->{filters}->{$what_filter} };
    foreach my $index ( 0 .. $#filter ) {
        my %filter = %{ $filter[$index] };
        $working_filter .= "Filter: $filter{'column'} != $filter{'output'}\n";
    }
    return $working_filter;
}

method filter_groups (HashRef $config, ArrayRef $groups) {
    my @filtered_groups = ();
    foreach my $group ( @{$groups} ) {
        unless ( any { $_ eq $group }
            @{ $config->{filters}->{'hide-hostgroups'} } )
        {
            push @filtered_groups, $group;
        }
    }
    return \@filtered_groups;
}

1;
