class vault (
  String  $user             = lookup('vault::user'),
  Boolean $manage_user      = lookup('vault::manage_user'),
  String  $group            = lookup('vault::group'),
  Boolean $manage_group     = lookup('vault::manage_group'),
  String  $bin_dir          = lookup('vault::bin_dir'),
  String  $config_dir       = lookup('vault::config_dir'),
  Boolean $purge_config_dir = lookup('vault::purge_config_dir'),
  String  $service_name     = lookup('vault::service_name'),
  Boolean $service_enable   = lookup('vault::service_enable'),
  String  $version          = lookup('vault::version'),
  String  $package_ensure   = lookup('vault::package_ensure'),
  String  $package_provider = lookup('vault::package_provider'),
  String  $package_source   = lookup('vault::package_source'),
) {

  package { 'vault':
    ensure   => $package_ensure,
    provider => $package_provider,
    source   => $package_source,
  }

  user { $user:
    ensure     => present,
    managehome => $manage_user,
  }

  group { $group:
    ensure => present,
  }

  file { $config_dir:
    ensure  => directory,
    purge   => $purge_config_dir,
    recurse => true,
  }

  service { $service_name:
    ensure  => running,
    enable  => $service_enable,
    require => Package['vault'],
  }
}
