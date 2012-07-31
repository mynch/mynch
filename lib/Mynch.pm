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

    $r->route('/')->to( controller => 'wallscreen', action => 'main_page' );

    $r->route('/wallscreen/:action')->to(
        controller => 'wallscreen',
        action     => 'main_page',
    );

    $r->route('/wallscreen/hostgroup/:show_hostgroups')
        ->to( controller => 'wallscreen', action => 'main_page', show_hostgroups => '' );

    $r->route('/dashboard/:action')->to(
        controller => 'dashboard',
        action => 'main_page'
    );

    $r->route('/dashboard/hostgroup/:show_hostgroups')
        ->to( controller => 'dashboard', action => 'main_page', show_hostgroups => '' );

    $r->route('/settings/:action')->to(
        controller => 'settings',
        action     => 'settings_page',
    );

    $r->route('/reports')->to( controller => 'reports', action => 'index' );
    $r->route('/report/migration')
        ->to( controller => 'reports', action => 'migration_report' );

}

1;
