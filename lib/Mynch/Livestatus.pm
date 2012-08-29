# Copyright: 2012 Erik Inge Bolsø <knan@redpill-linpro.com>
# Copyright: 2012 Lars Olavsen <larso@redpill-linpro.com>
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

package Mynch::Livestatus;
use Mojo::Base -base;
use Monitoring::Livestatus;
use Method::Signatures;
use Contextual::Return;

method connect( Str :$readwrite ) {
    my $config_ref = $self->{config};
    my %config     = %{$config_ref};
    my $conn;
    if (exists $config{'read'} and exists $config{'write'})
    {
      if ($readwrite eq "READ") {
          $conn = Monitoring::Livestatus->new(%{ $config{'read'} });
      }
      elsif ($readwrite eq "WRITE")
      {
          $conn = Monitoring::Livestatus->new(%{ $config{'write'} });
      }
    }
    else
    {
        $conn = Monitoring::Livestatus->new(%config);
    }

    return $conn;
}

method fetch( Str $query) {
    my $conn = $self->connect (readwrite => 'READ');

    my $results_ref = $conn->selectall_arrayref($query);

    return FAIL {$Monitoring::Livestatus::ErrorMessage}
    if ($Monitoring::Livestatus::ErrorCode);
    return $results_ref;
}

method send_commands( Str $commands) {
    my $conn = $self->connect (readwrite => 'WRITE');

    my @messages = split( /\n/, $commands );
    foreach my $line (@messages) {
        my $command = sprintf( "COMMAND [%d] %s\n", time(), $line );
        $conn->do($command);
    }
    return;
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
