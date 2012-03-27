package Mynch;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;
    $self = $self->secret('very-secret-password');

    # Router
    my $r = $self->routes;

    $r->route('/hostgroups')
        ->to( controller => 'livestatus', action => 'hostgroups' );
    $r->route('/hostgroups/:hostgroup')
        ->to( controller => 'livestatus', action => 'hostgroups' );

    $r->route('/services')
        ->to( controller => 'livestatus', action => 'servicesbyhostgroup' );
    $r->route('/services/hostgroup/:hostgroup')
        ->to( controller => 'livestatus', action => 'servicesbyhostgroup' );
}

1;
