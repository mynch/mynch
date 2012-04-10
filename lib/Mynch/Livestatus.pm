package Mynch::Livestatus;
use Mojo::Base -base;
use Monitoring::Livestatus;

sub connect {
    my $self = shift;
    my $config_ref = $self->{config};
    my %config = %{ $config_ref };

    my $conn = Monitoring::Livestatus->new( %config );

    return $conn;
}

sub fetch {
    my $self  = shift;
    my $query = shift;
    my $conn = $self->connect;

    my $results_ref = $conn->selectall_arrayref($query);

    if ($Monitoring::Livestatus::ErrorCode) {
        croak($Monitoring::Livestatus::ErrorMessage);
    }
    return $results_ref;
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
