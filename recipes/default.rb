#
# Cookbook Name:: users
# Recipe:: sysadmins
#
# Copyright 2011, Craig S. Cottingham.
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

case node[:platform]
# when "ubuntu","debian"
#   adduser_cmd = 'useradd'
# when "centos"
#   adduser_cmd = 'useradd'
when "amazon"
  adduser_cmd = 'useradd'
end

search(:users) { | u |
  name = u['name']
  comment = u['comment']
  create_home = u['create_home'] || node[:users][:create_home]
  groups = u['groups'] || node[:users][:groups]
  home_dir = u['home_dir']
  # password = u['password']
  shell = u['shell'] || node[:users][:shell]
  user_group = u['user_group'] | node[:users][:user_group]
  
  options = []
  options << "--comment '#{comment}'" unless comment.nil?
  options << "--create-home" if create_home
  options << "--groups '#{groups}'" unless groups.nil?
  options << "--home '#{home_dir}'" unless home_dir.nil?
  # options << "--password '#{password}'" unless password.nil?
  options << "--shell '#{shell}'" unless shell.nil?
  options << "--user-group" if user_group
  
  bash "add user" do
    user "root"
    code "#{adduser_cmd} #{name} #{options.join(' ')}"
  end

  # this instead of the above?
  # user u['id'] do
  #   uid u['uid']
  #   gid u['gid']
  #   shell u['shell']
  #   comment u['comment']
  #   supports :manage_home => true
  #   home home_dir
  # end
}
