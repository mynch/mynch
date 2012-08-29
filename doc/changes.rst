=======================
Changes from 0.2 to 0.3
=======================

Integration
-----------

- Support reading and writing to different sets of Icinga/Nagios
  servers.

  This ensures we can switch state on active/backup monitoring
  clusters without losing state.

- Add links back to the Icinga/Nagios web interface for hosts and
  services.

Bootstrap
---------

- Upgrade Twitter Bootstrap from 2.0.4 to 2.1.0

Other
-----

- Remove site specific "Reports" module.

- New perl dependencies: Date::Format and URI::Escape
