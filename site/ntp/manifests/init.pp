# Class: ntp
#
# Component module. Genuinely important on rancher1-3/master1-3
# specifically — certificate validity windows (notBefore/notAfter) are
# checked against each node's own clock; meaningful clock drift across
# the CA/master fleet can cause exactly the kind of "certificate
# verify failed" errors this whole build has already chased down more
# than once for other reasons.
#
# @param servers List of upstream NTP servers.
class ntp (
  Array[String] $servers = ['0.centos.pool.ntp.org', '1.centos.pool.ntp.org'],
) {

  package { 'ntp':
    ensure => present,
  }

  file { '/etc/ntp.conf':
    ensure  => file,
    content => template('ntp/ntp.conf.erb'),
    require => Package['ntp'],
    notify  => Service['ntpd'],
  }

  service { 'ntpd':
    ensure  => running,
    enable  => true,
    require => Package['ntp'],
  }
}
