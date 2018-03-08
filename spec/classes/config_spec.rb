require 'spec_helper'

describe 'zookeeper::config' do
  shared_examples 'debian-install' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}

    it { should contain_file(cfg_dir).with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { should contain_file(log_dir).with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { should contain_file(id_file).with({
      'ensure'  => 'file',
      'owner'   => user,
      'group'   => group,
    }).with_content(myid) }

  end

  context 'on debian-like system' do
    let(:user)    { 'zookeeper' }
    let(:group)   { 'zookeeper' }
    let(:cfg_dir) { '/etc/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper' }
    let(:id_file) { '/etc/zookeeper/conf/myid' }
    let(:myid)    { /1/ }

    it_behaves_like 'debian-install', 'Debian', 'wheezy'
  end

  context 'custom parameters' do
    # set custom params
    let(:params) { {
      :id      => '2',
      :user    => 'zoo',
      :group   => 'zoo',
      :cfg_dir => '/var/lib/zookeeper/conf',
      :log_dir => '/var/lib/zookeeper/log',
    } }


    let(:user)    { 'zoo' }
    let(:group)   { 'zoo' }
    let(:cfg_dir) { '/var/lib/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper/log' }
    let(:id_file) { '/var/lib/zookeeper/conf/myid' }
    let(:myid)    { /2/ }

    it_behaves_like 'debian-install', 'Debian', 'wheezy'
  end

  context 'extra parameters' do
    snap_cnt = 15000
    # set custom params
    let(:params) { {
      :log4j_prop    => 'INFO,ROLLINGFILE',
      :snap_count    => snap_cnt,
    } }

    it {
      should contain_file('/etc/zookeeper/conf/environment').with_content(/INFO,ROLLINGFILE/)
    }

    it {
      should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/snapCount=15000/)
    }
  end

  context 'log4j file' do
    let(:params) { {
      :log4j_file    => "/nail/etc/zookeeper/log4j.properties",
    } }

    it do
      should contain_file('/etc/zookeeper/conf/log4j.properties').with(
          'ensure' => 'link',
          'target' => log4j_file,
      )
    end
  end

  context 'max allowed connections' do
    max_conn = 15

    let(:params) {{
      :max_allowed_connections => max_conn
    }}

    it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/maxClientCnxns=#{max_conn}/) }
  end

  context 'datalogstore' do
    let(:params)  {{
      :datalogstore => '/tmp/log'

    }}
    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/dataLogDir=\/tmp\/log/) }
  end

  context 'restart zookeeper default' do
    it { should contain_file(
      '/etc/zookeeper/conf/myid'
    ).that_notifies('Class[zookeeper::service]') }
    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).that_notifies('Class[zookeeper::service]') }
    it { should contain_file(
      '/etc/zookeeper/conf/environment'
    ).that_notifies('Class[zookeeper::service]') }
    it { should contain_file(
      '/etc/zookeeper/conf/log4j.properties'
    ).that_notifies('Class[zookeeper::service]') }
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
    ).that_notifies('Class[zookeeper::service]') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).that_notifies('Class[zookeeper::service]') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/environment'
    ).that_notifies('Class[zookeeper::service]') }
    it { should_not contain_file(
      '/etc/zookeeper/conf/log4j.properties'
    ).that_notifies('Class[zookeeper::service]') }
  end
end
