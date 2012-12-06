=======
 Mynch
=======

About Mynch
-----------

Mynch is a clean, simple web interface to one or more monitoring
servers running Icinga or Nagios, with the MK Livestatus event broker
module installed.

Mynch is Free Software, see COPYING for details.

Installing
----------

For the Mynch instance, you need the following Perl modules:

* Contextual::Return
* Date::Format
* Digest::SHA
* File::Basename
* File::Spec::Functions
* List::MoreUtils
* Method::Signatures
* Mojolicious >= 2.82
* Monitoring::Livestatus
* Quantum::Superpositions
* URI::Escape

To run the tests, you also need:

* Test::Class
* Test::Mojo
* Test::More
* Time::Duration
* Time::Local

* A working monitoring server
* A "mynch.conf" configuration file in the repository root directory

On the monitoring server, you need:

* Icinga or Nagios
* MK Livestatus
* A tcp port to the MK Livestatus socket if mynch and monitoring are
  different hosts.  (use xinetd, systemd, netcat, etc…)

Security
--------

Mynch can read the state of your monitoring server, and send commands,
if the command socket is enabled. You should limit access to your
Mynch instance, either using a firewall, or placing it behind a web
server that can ask for a username and password.
