groups = search(:groups)

groups.each do |group|
  group group[:id] do
    group_name group[:id]
    gid group[:gid]
    action [ :create, :modify, :manage ]
  end

  if node[:active_groups].include?(group[:id])
    search(:users, "groups:#{group[:id]}").each do |user|
      user user[:id] do
        comment user[:comment]
        uid user[:uid]
        gid user[:groups].first
        home "/home/#{user[:id]}"
        shell "/bin/bash"
        password user[:password]
        supports :manage_home => true
        action [:create, :manage]
      end
      
      user[:groups].each do |g|
        group g do
          group_name g.to_s
          gid group[:gid]
          members [user[:id]]
          append true
          action [ :create, :modify, :manage ]
        end
      end

      directory "/home/#{user[:id]}/.ssh" do
        action :create
        owner user[:id]
        group user[:groups].first.to_s
        mode 0700
      end

      keys = Mash.new
      keys[user[:id]] = user[:ssh_key]

      if user[:ssh_key_groups]
        user[:ssh_key_groups].each do |group|
          users = search(:users, "groups:#{group}")
          users.each do |key_user|
            keys[key_user[:id]] = key_user[:ssh_key]
          end
        end
      end
      
      if user[:extra_ssh_keys]
        user[:extra_ssh_keys].each do |username|
          keys[username] = search(:users, "id:#{username}").first[:ssh_key]
        end
      end

      template "/home/#{user[:id]}/.ssh/authorized_keys" do
        source "authorized_keys.erb"
        action :create
        owner user[:id]
        group user[:groups].first.to_s
        variables(:keys => keys)
        mode 0600
        not_if { user[:preserve_keys] }
      end
    end
  end
end

# Remove initial setup user and group.
user  "ubuntu" do
  action :remove
end

group "ubuntu" do
  action :remove
end
