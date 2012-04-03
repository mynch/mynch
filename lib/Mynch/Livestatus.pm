package Mynch::Livestatus;
use Mojo::Base -base;
use Monitoring::Livestatus;

sub fetch {
    my $self  = shift;
    my $query = shift;

    my $conn
        = Monitoring::Livestatus->new( server => 'icinga.example.org:6557', );

    my $results_ref = $conn->selectall_arrayref($query);

    if ($Monitoring::Livestatus::ErrorCode) {
        croak($Monitoring::Livestatus::ErrorMessage);
    }
    return $results_ref;
}

sub _filter {
    my $self = shift;
    my ($args) = @_;

    my $filter;

    my @groups = split( /,/, $self->param( $args->{'param'} ) );
    my @filters = map {
        sprintf( "Filter: %s %s %s\n",
            $args->{'column'}, $args->{'operator'}, $_ )
    } @groups;

    $filter .= join( "", @filters );
    if ( scalar(@filters) > 1 ) {
        $filter .= sprintf( "Or: %d", scalar(@filters) );
    }

    $self->app->log->debug( "Filter: " . $filter );

    return $filter;
}

sub massage {
    my $self        = shift;
    my $src_ref     = shift;
    my $columns_ref = shift;

    my @src     = @$src_ref;
    my @columns = @$columns_ref;
    my @dst;

    foreach (@src) {
        my %tmp;
        @tmp{@columns} = @$_;
        push( @dst, {%tmp} );
    }

    return \@dst;
}

1;
