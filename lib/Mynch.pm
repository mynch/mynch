package Mynch;
use Mojo::Base 'Mojolicious';

use Mynch::Helpers;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Plugins
    $self->plugin('PODRenderer');
    $self->plugin('Mynch::Helpers');
    $self->plugin('Config');

    if ($self->config->{secret}) {
        $self->secret($self->config->{secret});
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

    $r->route('/wallscreen/problems')
        ->to(controller => 'wallscreen', action => 'problem_page' );

}

1;
