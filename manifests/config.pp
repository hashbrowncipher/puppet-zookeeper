# Class: zookeeper::config
#
# This module manages the zookeeper configuration directories
#
# Parameters:
# [* id *]  zookeeper instance id: between 1 and 255
#
# [* servers *] an Array - specify all zookeeper servers
# The fist port is used by followers to connect to the leader
# The second one is used for leader election
#     server.1=zookeeper1:2888:3888
#     server.2=zookeeper2:2888:3888
#     server.3=zookeeper3:2888:3888
#
# [* log4j_file *] Set to undef by default, if not full path to log4j
# properties file is required, that will be the target of symlink from
# $cfg_dir/log4j.properties. This file needs to be present and deployed
# beforehand. This is useful when one wants to template and deploy their
# own log4j properties for zookeeper logging.
#
#
# Actions: None
#
# Requires: zookeeper::install, zookeeper
#
# Sample Usage: include zookeeper::config
#
class zookeeper::config(
  $id                    = '1',
  $datastore             = '/var/lib/zookeeper',
  $datalogstore          = undef,
  $client_port           = 2181,
  $snap_count            = 10000,
  $log_dir               = '/var/log/zookeeper',
  $cfg_dir               = '/etc/zookeeper/conf',
  $user                  = 'zookeeper',
  $group                 = 'zookeeper',
  $java_bin              = '/usr/bin/java',
  $java_opts             = '',
  $pid_dir               = '/var/run/zookeeper',
  $pid_file              = '$PIDDIR/zookeeper.pid',
  $zoo_main              = 'org.apache.zookeeper.server.quorum.QuorumPeerMain',
  $log4j_prop            = 'INFO,ROLLINGFILE',
  $servers               = [''],
  # since zookeeper 3.4, for earlier version cron task might be used
  $snap_retain_count     = 3,
  # interval in hours, purging enabled when >= 1
  $purge_interval        = 0,
  # log4j properties
  $rollingfile_threshold = 'ERROR',
  $tracefile_threshold   = 'TRACE',
  $max_allowed_connections = 10,
  $quorum_listen_on_all_ips = true,
  $tick_time = 2000,
  $init_limit = 10,
  $sync_limit = 5,
  $log4j_file = undef,
) {
  require zookeeper::install

  if $log4j_file {
    validate_absolute_path($log4j_file)
    if $log4j_file == "${cfg_dir}/log4j.properties" {
        fail('log4j_file should not be same as ' + "${cfg_dir}/log4j.properties")
    }
  }

  file { $cfg_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0644',
  }

  file { $log_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  file { $datastore:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  if $datalogstore {
    file { $datalogstore:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0644',
    }
  }

  file { "${cfg_dir}/myid":
    ensure  => file,
    content => template('zookeeper/conf/myid.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => File[$cfg_dir],
  }

  file { "${cfg_dir}/zoo.cfg":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/zoo.cfg.erb'),
    require => File[$cfg_dir],
  }

  file { "${cfg_dir}/environment":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/environment.erb'),
    require => File[$cfg_dir],
  }

  if $log4j_file {
    file { "${cfg_dir}/log4j.properties":
        ensure  => 'link',
        owner   => $user,
        group   => $group,
        mode    => '0644',
        target  => $log4j_file,
        require => File[$log4j_file],
    }
  } else {
    file { "${cfg_dir}/log4j.properties":
        owner   => $user,
        group   => $group,
        mode    => '0644',
        content => template('zookeeper/conf/log4j.properties.erb'),
    }
  }

}
