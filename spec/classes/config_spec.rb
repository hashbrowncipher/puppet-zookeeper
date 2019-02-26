require 'spec_helper'

describe 'zookeeper::config' do
  shared_examples 'debian-install' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Ubuntu',
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

    it { should contain_file(env_file).with({
      'owner'   => user,
      'group'   => group,
    }).with_content(/NAME=zookeeper/) }

  end

  context 'on debian-like system' do
    let(:user)    { 'zookeeper' }
    let(:group)   { 'zookeeper' }
    let(:cfg_dir) { '/etc/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper' }
    let(:id_file) { '/etc/zookeeper/conf/myid' }
    let(:env_file) { '/etc/zookeeper/conf/environment' }
    let(:myid)    { /1/ }

    it_behaves_like 'debian-install', 'Ubuntu', 'trusty'
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
    let(:env_file) { '/var/lib/zookeeper/conf/environment' }

    it_behaves_like 'debian-install', 'Ubuntu', 'trusty'
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
          'target' => '/nail/etc/zookeeper/log4j.properties',
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

  context 'quorum listen on all ips' do
    quorum_listen_on_all_ips = false

    let(:params) {{
      :quorum_listen_on_all_ips => quorum_listen_on_all_ips
    }}

    it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/quorumListenOnAllIPs=#{quorum_listen_on_all_ips}/) }
  end

  context 'datalogstore' do
    let(:params)  {{
      :datalogstore => '/tmp/log'

    }}
    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/dataLogDir=\/tmp\/log/) }
  end
end
