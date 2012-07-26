package Mynch::Livestatus;
use Mojo::Base -base;
use Monitoring::Livestatus;
use Method::Signatures;
use Contextual::Return;

method connect {
    my $config_ref = $self->{config};
    my %config     = %{$config_ref};

    my $conn = Monitoring::Livestatus->new(%config);

    return $conn;
}

method fetch( Str $query) {
    my $conn = $self->connect;

    my $results_ref = $conn->selectall_arrayref($query);

    return FAIL { $Monitoring::Livestatus::ErrorMessage }
      if ($Monitoring::Livestatus::ErrorCode);
    return $results_ref;
}

method massage( ArrayRef $src_ref, ArrayRef $columns_ref) {
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
