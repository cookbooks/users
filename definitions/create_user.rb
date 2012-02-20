#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright (c) 2011 Craig S. Cottingham.
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

define :create_user, :details => nil do
  
  u = params[:details]
  home_dir = u['home']
  home_dir = "/home/#{params[:name]}" if home_dir.nil?
  
  user params[:name] do
    comment u['comment']
    uid u['uid']
    gid u['gid']
    home home_dir
    shell u['shell']
    password u['password']
    supports :manage_home => true
  end

  unless u['groups'].nil?
    u['groups'].each do | g |
      group g do
        members [ params[:name] ]
        append true
      end
    end
  end

  unless u['ssh_keys'].nil?

    directory "#{home_dir}/.ssh" do
      owner params[:name]
      group u['gid'] || params[:name]
      mode "0700"
    end

    template "#{home_dir}/.ssh/authorized_keys" do
      source "authorized_keys.erb"
      owner params[:name]
      group u['gid'] || params[:name]
      mode "0600"
      variables :ssh_keys => u['ssh_keys']
    end

  end
  
end
