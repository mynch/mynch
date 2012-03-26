package Mynch;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;
  $self = $self->secret('very-secret-password');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->route('/')->to('example#welcome');

  $r->route('/json')->to(controller => 'json', action => 'raw');

  $r->route('/services')->to(controller => 'livestatus', action => 'servicesbyhostgroup');
  $r->route('/services/hostgroup/:hostgroup')->to(controller => 'livestatus', action => 'servicesbyhostgroup');
}

1;
