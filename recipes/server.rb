#
# Author:: Matt Ray <matt@chef.io>
# Cookbook Name:: tftp
# Recipe:: server
#
# Copyright 2011-2015, Chef Software, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'rhel', 'fedora'
  package 'tftp-server'

  directory node['tftp']['directory'] do
    owner node['tftp']['owner']
    group node['tftp']['group']
    mode '0755'
    recursive true
    action :create
  end

  template '/etc/xinetd.d/tftp' do
    source 'tftp.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[xinetd]'
  end

  service 'xinetd' do
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end

when 'debian'
  package 'tftpd-hpa'

  directory node['tftp']['directory'] do
    owner node['tftp']['owner']
    group node['tftp']['group']
    mode '0755'
    recursive true
    action :create
  end

  template '/etc/default/tftpd-hpa' do
    owner 'root'
    group 'root'
    mode '0644'
    source 'tftpd-hpa.erb'
    notifies :restart, 'service[tftpd-hpa]'
  end

  service 'tftpd-hpa' do
    restart_command 'service tftpd-hpa restart'
    start_command 'service tftpd-hpa start'
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end
else
  Chef::Log.warn("#{cookbook_name}::#{recipe_name} recipe is not supported on #{node['platform_family']}")
end
