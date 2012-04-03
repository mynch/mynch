package Mynch;
use Mojo::Base 'Mojolicious';

use Mynch::Helpers;

# This method will run once at server start
sub startup {
    my $self = shift;
    $self->secret('very-secret-password');

    # Plugins
    $self->plugin('PODRenderer');
    $self->plugin('Mynch::Helpers');

    # Router
    my $r = $self->routes;

    $r->route('/wallscreen')
        ->to(controller => 'wallscreen', action => 'main_page' );
    $r->route('/wallscreen/status')
        ->to(controller => 'wallscreen', action => 'status_page' );
    $r->route('/wallscreen/log')
        ->to(controller => 'wallscreen', action => 'log_page' );

}

1;
