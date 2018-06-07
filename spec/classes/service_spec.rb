require 'spec_helper'

describe 'zookeeper::service' do
  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
  }}

  it { should contain_package('zookeeperd') }
  it { should contain_service('zookeeper').with(
    :ensure => 'running',
    :enable => true
  )}


  context 'restart zookeeper default' do
    it { should contain_file(
      '/etc/zookeeper/conf/myid'
    ).that_notifies('Service[zookeeper]') }
    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).that_notifies('Service[zookeeper]') }
    it { should contain_file(
      '/etc/zookeeper/conf/environment'
    ).that_notifies('Service[zookeeper]') }
    it { should contain_file(
      '/etc/zookeeper/conf/log4j.properties'
    ).that_notifies('Service[zookeeper]') }
  end

  context 'restart zookeeper false' do
    let(:params)  {{
      :restart_zookeeper => false

    }}
    it { should contain_file(
      '/etc/zookeeper/conf/myid') }
    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg') }
    it { should contain_file(
      '/etc/zookeeper/conf/environment') }
    it { should contain_file(
      '/etc/zookeeper/conf/log4j.properties') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/myid'
    ).that_notifies('Service[zookeeper]') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).that_notifies('Service[zookeeper]') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/environment'
    ).that_notifies('Service[zookeeper]') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/log4j.properties'
    ).that_notifies('Service[zookeeper]') }
  end
end
