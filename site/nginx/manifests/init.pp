# Class: nginx
#
# @param package_ensure Desired package state.
# @param service_ensure Desired service state.
# @param service_enable Whether enabled at boot.
# @param listen_port Port nginx listens on.
class nginx (
  String                     $package_ensure = 'present',
  Enum['running', 'stopped'] $service_ensure = 'running',
  Boolean                    $service_enable = true,
  Integer[1, 65535]          $listen_port    = 80,
) inherits nginx::params {

  package { $nginx::params::package_name:
    ensure => $package_ensure,
  }

  file { "${nginx::params::config_dir}/default.conf":
    ensure  => file,
    content => "server {\n    listen ${listen_port};\n    location / {\n        return 200 'nginx managed by Puppet — role::webserver\\n';\n    }\n}\n",
    require => Package[$nginx::params::package_name],
    notify  => Service[$nginx::params::service_name],
  }

  service { $nginx::params::service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package[$nginx::params::package_name],
  }
}
