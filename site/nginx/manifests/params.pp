# Class: nginx::params
#
# Component module — generic, reusable, no business logic, no Hiera
# lookups. Every organization-specific decision (which port, which
# package version) lives in profile::webserver instead.
class nginx::params {
  case $facts['os']['family'] {
    'RedHat': {
      $package_name = 'nginx'
      $service_name = 'nginx'
      $config_dir   = '/etc/nginx/conf.d'
    }
    default: {
      fail("nginx module does not support ${facts['os']['family']}")
    }
  }
}
