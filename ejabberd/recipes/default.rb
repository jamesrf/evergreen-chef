package "ejabberd"

service "ejabberd" do
  action :enable
  supports :restart => true
end

template "/etc/ejabberd/ejabberd.cfg" do
  source "ejabberd.cfg.erb"
  owner "ejabberd"
  group "ejabberd"
  variables(:jabber_hosts => ["localhost","private.localhost","public.localhost"],
            :max_rate => 500000,
            :max_stanza_size => 2000000,
            :max_user_sessions => 10000 )
  notifies :restart, resources(:service => "ejabberd"), :immediately
end

# execute "add ejabberd admin user" do
#   command "ejabberdctl register admin #{node[:base][:jabber_domain]} #{node[:base][:jabber_admin_password]}"
# end

service "ejabberd" do
  action :start
end
