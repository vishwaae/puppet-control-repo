# Class: profile::webserver
#
# PROFILE — the "what": combines the generic nginx component module
# with data specific to how this org runs a webserver, plus a
# scheduled maintenance job via the custom cronmanage type/provider
# (Ruby) from the practice modules.
#
# Deliberately targets worker* nodes EXCLUDING worker2 — see the
# hammer command below; worker2 runs Foreman's own web UI under httpd,
# and Puppet-managing an unrelated web stack there risks interfering
# with the very install this whole build fought to get working.
class profile::webserver {

  class { 'nginx':
    listen_port => lookup('profile::webserver::port', Integer, 'first', 80),
  }

  # managed_cron_job — custom Puppet TYPE + PROVIDER, pure Ruby
  # (lib/puppet/type/managed_cron_job.rb, lib/puppet/provider/...).
  # This is the "Ruby" half of the DSL+Ruby combination on this side.
  managed_cron_job { 'webserver-log-rotate':
    ensure  => present,
    command => '/usr/sbin/logrotate /etc/logrotate.d/nginx',
    hour    => '3',
    minute  => '15',
  }
}
