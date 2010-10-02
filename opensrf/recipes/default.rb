directory "/home/opensrf"  do
  action :create
  not_if "test -d /home/opensrf"
  mode "0775"
end

user "opensrf" do
  home "/home/opensrf"
  shell "/bin/bash"
end

execute "fixosrfperms" do
  user "root"
  command "chown -R opensrf:opensrf /home/opensrf"
end

template "/etc/hosts" do
    source "hosts.erb"
    mode 0644
    owner "root"
    group "root"
end

template "/home/opensrf/.profile" do
    source "profile.erb"
    mode 0640
    owner "opensrf"
    group "opensrf"
end

template "/home/opensrf/.bashrc" do
    source "bashrc.erb"
    mode 0640
    owner "opensrf"
    group "opensrf"
end

require_recipe "apt"
require_recipe "perl"
require_recipe "apache2"
require_recipe "ejabberd"
require_recipe "memcached"

execute "wipe_mnesia" do
  user "root"
  command "pgrep -u ejabberd|xargs kill ; rm /var/lib/ejabberd/*"
  notifies :restart, resources(:service => "ejabberd"), :immediately
end

package "apache2-mpm-prefork"
package "apache2-prefork-dev"
package "autoconf"
package "automake"
package "build-essential"
package "less"
package "libapache2-mod-perl2"
package "libmemcached-dev"
package "libclass-dbi-abstractsearch-perl"
package "libclass-dbi-sqlite-perl"
package "libdatetime-format-builder-perl"
package "libdatetime-format-mail-perl"
package "libdatetime-perl"
package "libdatetime-timezone-perl"
package "liberror-perl"
package "libexpat1-dev"
package "libfile-find-rule-perl"
package "libfreezethaw-perl"
package "libgcrypt11-dev"
package "libgdbm-dev"
package "liblog-log4perl-perl"
package "libmodule-build-perl"
package "libnet-jabber-perl"
package "libperl-dev"
package "libreadline5-dev"
package "librpc-xml-perl"
package "libtemplate-perl"
package "libtest-pod-perl"
package "libtie-ixhash-perl"
package "libtool"
package "libuniversal-require-perl"
package "libunix-syslog-perl"
package "libwww-perl"
package "libxml2-dev"
package "libxml-libxml-perl"
package "libxml-libxslt-perl"
package "libxml-simple-perl"
package "libxslt1-dev"
package "ntpdate"
package "pkg-config"
package "psmisc"
package "python-dev"
package "python-libxml2"
package "python-setuptools"



# ========= EJABBERD USERS ==============

#=end

execute "register_public_router" do
	user "root"
    command "ejabberdctl register #{node[:opensrf][:public][:router][:username]} public.localhost #{node[:opensrf][:private][:router][:password]}"
end

execute "register_public_gateway" do
	user "root"
    command "ejabberdctl register #{node[:opensrf][:public][:gateway][:username]} private.localhost #{node[:opensrf][:public][:gateway][:password]}" 
end

execute "register_private_router" do
	user "root"
    command "ejabberdctl register #{node[:opensrf][:private][:router][:username]} private.localhost #{node[:opensrf][:private][:router][:password]}" 
end

execute "register_private_gateway" do
	user "root"
    command "ejabberdctl register #{node[:opensrf][:private][:gateway][:username]} public.localhost #{node[:opensrf][:private][:gateway][:password]}" 
end


#========= CORE OPENSRF INSTALL ===========

package "subversion"

subversion "OpenSRF" do
  user "opensrf"
  group "opensrf"
  repository "#{node[:opensrf][:svnrepo]}"
  destination "#{node[:opensrf][:folder]}"
  action :sync
end


bash "make_opensrf" do
  user "opensrf"
  group "opensrf"
  code <<-EOH
  cd "#{node[:opensrf][:folder]}"
  ./autogen.sh
  ./configure --prefix=#{node[:opensrf][:prefix]}  --sysconfdir=#{node[:opensrf][:sysconfdir]}
  make
  EOH
end


bash "install_opensrf" do
  user "root"
  code <<-EOH
  cd "#{node[:opensrf][:folder]}"
  make install
  chown -R opensrf:opensrf #{node[:opensrf][:prefix]}
  EOH
end

template "/etc/ld.so.conf.d/osrf.conf" do
    source "osrf-ld.conf.erb"
    mode 0640
    owner "root"
    group "root"
end

execute "reloadldconf" do
	user "root"
	command "ldconfig"
end

template "/openils/conf/opensrf.xml" do
    source "opensrf.xml.erb"
    mode 0600
    owner "opensrf"
    group "opensrf"
end

template "/openils/conf/opensrf_core.xml" do
    source "opensrf_core.xml.erb"
    mode 0600
    owner "opensrf"
    group "opensrf"
end

template "/home/opensrf/.srfsh.xml" do
    source "srfsh.xml.erb"
    mode 0600
    owner "opensrf"
    group "opensrf"
end
