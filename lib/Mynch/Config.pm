package Mynch::Config;
use Mojo::Base -base;
use Method::Signatures;
use Contextual::Return;

method build_filter ( HashRef $config, Str $what_filter ){
     my $working_filter;

     my @filter = @{$config->{filters}->{$what_filter}};
     foreach my $index (0 .. $#filter) {
        my %filter = %{$filter[$index]};
        $working_filter .= "Filter: $filter{'column'} != $filter{'output'}\n";
     }
     return $working_filter;
}

1;
