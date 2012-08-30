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
use Method::Signatures;

# This method will run once at server start
method startup {

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

    # Session lifetime (1 year)
    $self->sessions->default_expiration(31536000);

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

    $self->defaults( user => 'vaktsmurfen' );

    $self->hook( before_dispatch => \&get_user );
}

method get_user {
    my $config = $self->config;

    if ( $config->{'user'} and $config->{'user'}->{'auth'} eq "header" ) {
        my $header = $config->{'user'}->{'header'};
        if ($header) {
            if ( $self->req->headers->header($header) ) {
                my $user = $self->req->headers->header($header);
                $self->stash( user => $user );
            }
        }
    }
    else {

        # default = REMOTE_USER
        if ( $self->req->env->{REMOTE_USER} ) {
            $self->stash( user => $self->req->env->{REMOTE_USER} );
        }
    }
}

1;
