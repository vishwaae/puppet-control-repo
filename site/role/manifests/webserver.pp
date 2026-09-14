# Class: role::webserver
#
# A ROLE — the "who": exactly what a node's Foreman hostgroup ENC
# assignment should point at. A node gets exactly ONE role, ever.
# Roles contain ONLY include statements for profiles — no resources,
# no logic, no Hiera lookups of their own. This is the class you type
# into Foreman's "Puppet ENC" tab for the webserver hostgroup — nothing
# else needs adding there.
class role::webserver {
  include profile::webserver
}
