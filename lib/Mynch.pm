package Mynch;
use Mojo::Base 'Mojolicious';

use Mynch::Helpers;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Plugins
    $self->plugin('Mynch::Helpers');
    $self->plugin('Config');

    if ($self->config->{secret}) {
        $self->secret($self->config->{secret});
    }

    # Read local plugins from configuration file
    foreach my $plugin (@{ $self->config->{plugins} }) {
        if ($plugin->{parameters}) {
            $self->plugin($plugin->{name}, $plugin->{parameters});
        }
        else {
            $self->plugin($plugin->{name});
        }
    }

    # Router
    my $r = $self->routes;

    $r->route('/wallscreen')
        ->to(controller => 'wallscreen', action => 'main_page' );
    $r->route('/wallscreen/status')
        ->to(controller => 'wallscreen', action => 'status_page' );
    $r->route('/wallscreen/log')
        ->to(controller => 'wallscreen', action => 'log_page' );

    $r->route('/wallscreen/hostgroups')
        ->to(controller => 'wallscreen', action => 'hostgroup_summary' );

    $r->route('/settings')
        ->to(controller => 'settings', action => 'settings_page' );
    $r->route('/settings/edit')
        ->to(controller => 'settings', action => 'edit_page' );
    $r->route('/settings/clear')
        ->to(controller => 'settings', action => 'clear_settings' );
    $r->route('/settings/delete')
        ->to(controller => 'settings', action => 'delete_set' );
    $r->route('/settings/add')
        ->to(controller => 'settings', action => 'add_set' );
    $r->route('/settings/save')
        ->to(controller => 'settings', action => 'save_set' );

    $r->route('/report/migration')
        ->to(controller => 'reports', action => 'migration_report' );

}

1;
