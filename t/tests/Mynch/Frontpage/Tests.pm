# Copyright: 2012 Stig Sandbeck Mathisen <ssm@redpill-linpro.com>
#

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

package Mynch::Frontpage::Tests;
use base qw(Mynch::Tests);

sub Load_frontpage : Test(2) {
    my $fixture = shift;
    $fixture->{mojo}->get_ok('/')->status_is(200);
}

1;
