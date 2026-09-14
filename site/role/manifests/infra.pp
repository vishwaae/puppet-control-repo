# Class: role::infra
#
# ROLE for rancher1-3/master1-3 — the class assigned in Foreman's ENC
# tab for the "infra" hostgroup. Contains only an include, same
# discipline as role::webserver.
class role::infra {
  include profile::infra
}
