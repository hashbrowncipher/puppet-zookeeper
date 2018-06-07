# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper/conf',
  $restart_zookeeper = true,
){
  require zookeeper::install
  require zookeeper::config
  validate_bool($restart_zookeeper)


  service { 'zookeeper':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      File["${cfg_dir}/zoo.cfg"]
    ]
  }

  if $restart_zookeeper {
    File["${cfg_dir}/myid"] ~> Service['zookeeper']
    File["${cfg_dir}/zoo.cfg"] ~> Service['zookeeper']
    File["${cfg_dir}/environment"] ~> Service['zookeeper']
    File["${cfg_dir}/log4j.properties"] ~> Service['zookeeper']
  }
}
