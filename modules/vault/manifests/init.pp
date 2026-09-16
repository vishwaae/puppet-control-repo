class vault (
  String  $user             = lookup('vault::user'),
  String  $manage_user      = lookup('vault::manage_user'),
  String  $group            = lookup('vault::group'),
  String  $bin_dir          = lookup('vault::bin_dir'),
  String  $config_dir       = lookup("vault::config_dir"),
  String  $service_name     = lookup('vault::service_name'),
  Boolean $manage_group     = lookup('vault::manage_group'),
  Boolean $purge_config_dir = lookup('vault::purge_config_dir'),
  Boolean $service_enable   = lookup('vault::service_enable'),
) {
  user { $user:
    ensure => present,
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
    ensure => running,
    enable => $service_enable,
  }
}
