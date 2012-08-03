package Mynch::Config;
use Mojo::Base -base;
use Method::Signatures;
use Contextual::Return;
use List::MoreUtils qw{ any };

method build_filter ( HashRef $config, Str $what_filter ){
     my $working_filter;

     my @filter = @{$config->{filters}->{$what_filter}};
     foreach my $index (0 .. $#filter) {
        my %filter = %{$filter[$index]};
        $working_filter .= "Filter: $filter{'column'} != $filter{'output'}\n";
     }
     return $working_filter;
}

method filter_groups (HashRef $config, ArrayRef $groups) {
    my @filtered_groups = ();
    foreach my $group (@{$groups}) {
        unless (any { $_ eq $group } @{$config->{filters}->{'hide-hostgroups'}})
        {
            push @filtered_groups, $group;
        }
    }
    return \@filtered_groups;
}

1;
