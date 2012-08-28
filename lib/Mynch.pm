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

package Mynch;
use Mojo::Base 'Mojolicious';

use Mynch::Helpers;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Plugins
    $self->plugin('Mynch::Helpers');
    $self->plugin('Config');

    if ( $self->config->{secret} ) {
        $self->secret( $self->config->{secret} );
    }

    # Read local plugins from configuration file
    foreach my $plugin ( @{ $self->config->{plugins} } ) {
        if ( $plugin->{parameters} ) {
            $self->plugin( $plugin->{name}, $plugin->{parameters} );
        }
        else {
            $self->plugin( $plugin->{name} );
        }
    }

    # Router
    my $r = $self->routes;

    $r->route('/')->to( controller => 'frontpage', action => 'frontpage' );

    $r->route('/wallscreen/:action')->to(
        controller => 'wallscreen',
        action     => 'main_page',
    );

    $r->route('/wallscreen/hostgroup/:show_hostgroups')->to(
        controller      => 'wallscreen',
        action          => 'main_page',
        show_hostgroups => ''
    );

    $r->route('/dashboard/:action')->to(
        controller => 'dashboard',
        action     => 'main_page'
    );

    $r->route('/dashboard/hostgroup/:show_hostgroups')->to(
        controller      => 'dashboard',
        action          => 'main_page',
        show_hostgroups => ''
    );

    $r->route('/dashboard/host/#show_host')->to(
        controller => 'dashboard',
        action     => 'host',
        show_host  => ''
    );

    $r->route('/dashboard/service/#show_host/#show_service')->to(
        controller   => 'dashboard',
        action       => 'service',
        show_host    => '',
        show_service => ''
    );

    $r->route('/settings/:action')->to(
        controller => 'settings',
        action     => 'settings_page',
    );

}

1;
