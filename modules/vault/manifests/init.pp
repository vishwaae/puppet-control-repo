class vault (
  String  $user             = lookup('vault::user'),
  Boolean $manage_user      = lookup('vault::manage_user'),
  String  $group            = lookup('vault::group'),
  Boolean $manage_group     = lookup('vault::manage_group'),
  String  $config_dir       = lookup('vault::config_dir'),
  Boolean $purge_config_dir = lookup('vault::purge_config_dir'),
  String  $service_name     = lookup('vault::service_name'),
  Boolean $service_enable   = lookup('vault::service_enable'),
  String  $package_ensure   = lookup('vault::package_ensure'),
  String  $repo_baseurl     = lookup('vault::repo_baseurl'),
  String  $repo_gpgkey      = lookup('vault::repo_gpgkey'),
  String  $listen_address   = lookup('vault::listen_address'),
  Integer $listen_port      = lookup('vault::listen_port'),
  Boolean $ui_enabled       = lookup('vault::ui_enabled'),
  Boolean $tls_disable      = lookup('vault::tls_disable'),
) {

  yumrepo { 'hashicorp':
    baseurl  => $repo_baseurl,
    descr    => 'HashiCorp Stable - $basearch',
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => $repo_gpgkey,
  }

  package { 'vault':
    ensure  => $package_ensure,
    require => Yumrepo['hashicorp'],
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

  file { "${config_dir}/config.hcl":
    ensure  => file,
    content => template('vault/config.hcl.erb'),
    require => File[$config_dir],
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure  => running,
    enable  => $service_enable,
    require => [Package['vault'], File["${config_dir}/config.hcl"]],
  }
}
