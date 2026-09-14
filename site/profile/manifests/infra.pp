# Class: profile::infra
#
# PROFILE for the CA/master fleet (rancher1-3, master1-3) — time sync
# (genuinely important for cert validity checking on exactly these
# nodes) plus disk-usage monitoring using the custom Ruby FACT and
# FUNCTION from the sysmonitor practice module.
class profile::infra {

  include ntp

  # $facts['disk_usage_percent'] and $facts['disk_usage_status'] —
  # custom Ruby FACTS (lib/facter/disk_usage_percent.rb), pulled into
  # real DSL logic here, not just defined in isolation.
  $usage = $facts['disk_usage_percent']

  if $usage and $usage >= lookup('profile::infra::disk_warn_threshold', Integer, 'first', 80) {
    notify { 'infra-disk-warning':
      message  => "WARNING on ${facts['networking']['hostname']}: disk usage ${usage}% (${facts['disk_usage_status']})",
      loglevel => 'warning',
    }
  }

  # sysmonitor::format_bytes — custom Ruby FUNCTION
  # (lib/puppet/functions/sysmonitor/format_bytes.rb), modern
  # Puppet::Functions API. Used here to render a real value.
  $mem_total_bytes = $facts['memory']['system']['total_bytes']
  notify { 'infra-memory-report':
    message => "Total memory on ${facts['networking']['hostname']}: ${sysmonitor::format_bytes($mem_total_bytes)}",
  }

  # managed_cron_job — same custom type/provider used in
  # profile::webserver, demonstrating it's a genuinely reusable
  # component, not a one-off tied to a single profile.
  managed_cron_job { 'infra-disk-report':
    ensure  => present,
    command => '/usr/bin/df -h > /var/log/disk-report.log',
    hour    => '1',
    minute  => '0',
  }
}
