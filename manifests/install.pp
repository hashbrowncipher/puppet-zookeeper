# Class: zookeeper::install
#
# This module manages Zookeeper installation
#
# Parameters: None
#
# Actions: None
#
# Requires:
#
# Sample Usage: include zookeeper::install
#
class zookeeper::install(
  $ensure            = present,
  $snap_retain_count = 3,
  $cleanup_sh        = '/usr/lib/zookeeper/bin/zkCleanup.sh',
  $datastore         = '/var/lib/zookeeper',
  $user              = 'zookeeper',
) {
# a debian (or other binary package) must be available, see https://github.com/deric/zookeeper-deb-packaging
# for Debian packaging
  package { ['zookeeper']:
    ensure => $ensure
  }

  if $::lsbdistcodename == 'xenial' {
      systemd::unit_file { 'zookeeper.service':
          # enable/active => true is not required here since
          # that also enables the automated restarted of zookeeper
          # which we manage through service.pp and notify.
          source  => 'puppet:///modules/zookeeper/zookeeper.service',
          require => Package['zookeeper'],
      }
  } else {
    package { ['zookeeperd']: #init.d scripts for zookeeper
      ensure  => $ensure,
      require => Package['zookeeper'],
    }
  }

  # if !$cleanup_count, then ensure this cron is absent.
  if ($snap_retain_count > 0 and $ensure != 'absent') {
    cron { 'zookeeper-cleanup':
        ensure  => present,
        command => "${cleanup_sh} ${datastore} ${snap_retain_count}",
        hour    => 2,
        minute  => 42,
        user    => $user,
        require => Package['zookeeper'],
    }
  }
}

