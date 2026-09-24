# Class: profile::base
#
# The ONE place ntp/resolve_conf/timezone get declared. Every role
# includes this — that's the actual reuse mechanism: the class
# declaration lives here once, not copy-pasted into every hostgroup's
# ENC list. The data itself lives once too, in common.yaml, reached
# by every node regardless of hostgroup via Hiera's own hierarchy
# fallback — this profile doesn't duplicate or re-declare any of that
# data, it just ensures the classes that consume it are applied
# everywhere consistently.
class profile::base {
  include ntp
  include resolve_conf
  include timezone
}
