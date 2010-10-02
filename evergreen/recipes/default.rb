# include the opensrf recipe
require_recipe "opensrf"

# moved to apache recipe
#apache_module "include"
#apache_module "expires"
#apache_module "rewrite"
#bash "make_ssl_key" do
  #user "root"
  #code <<-EOH
  #mkdir "/etc/apache2/ssl"
  #cd "/etc/apache2/ssl"
  #openssl req -batch -new -x509 -days 365 -nodes -out server.crt -keyout server.key
  #EOH
#end
#apache_module "ssl"

# debs from makefile
package "apache2-prefork-dev"
package "aspell"
package "aspell-en"
package "libbusiness-creditcard-perl"
package "libbusiness-onlinepayment-authorizenet-perl"
package "libbusiness-onlinepayment-perl"
package "libdatetime-format-builder-perl"
package "libdatetime-format-iso8601-perl"
package "libdatetime-format-mail-perl"
package "libdatetime-perl"
package "libdatetime-timezone-perl"
package "libdatetime-set-perl"
package "libdbd-pg-perl"
package "libemail-send-perl"
package "libgd-graph3d-perl"
package "liblog-log4perl-perl"
package "libmarc-record-perl"
package "libncurses5-dev"
package "libnet-server-perl"
package "libnspr4-dev"
package "libole-storage-lite-perl"
package "libparent-perl"
package "libpq-dev"
package "libreadline5-dev"
package "libspreadsheet-writeexcel-perl"
package "libssh2-1-dev"
package "libtext-aspell-perl"
package "libtext-csv-perl"
package "libuniversal-require-perl"
package "libunix-syslog-perl"


# extra debs
package "libbusiness-isbn-perl"
package "libbusiness-isbn-data-perl"
package "libmarc-charset-perl"
package "libmarc-xml-perl"
package "libnet-z3950-zoom-perl"
package "yaz"

# pg-client
package "postgresql-client"

# for translations
package "translate-toolkit"
package "python-dev"
package "python-setuptools"
package "python-lxml"

# this needs tweakery into a more full fledged cross-platformyness
case node[:lsb][:codename]
  when "hardy"
    package "libyaz2-dev"
  when "karmic"
    package "libyaz3-dev"
  when "lucid"
    package "libyaz3-dev"
end



# base CPAN installs
cpan_module "Business::EDI"
cpan_module "Library::CallNumber::LC"
cpan_module "Net::uFTP"
cpan_module "Net::Z3950::Simple2ZOOM"
cpan_module "SRU"

# cpan more
cpan_module "Business::CreditCard::Object"
cpan_module "MARC::Record"
cpan_module "UUID::Tiny"

# cpan safe
cpan_module "Safe"

# cpan force
#cpan_module "Class::DBI::Frozen::301"
#  force true
#end

# Call Numbers
bash "library-cn-lc" do
  user "root"
  code <<-EOH
  cd /tmp
  svn checkout http://library-callnumber-lc.googlecode.com/svn/trunk/ library-callnumber-lc-read-only
  cd library-callnumber-lc-read-only/perl/Library-CallNumber-LC
  perl Build.PL
  ./Build
  ./Build test
  ./Build install
  EOH
end


# ==== INSTALL SPIDERMONKEY =====
bash "install_js_sm" do
	user "root"
	code <<-EOH
  cd /tmp
	if [ ! -f #{node[:libjs][:version]}.tar.gz ]; then wget #{node[:libjs][:url]}; fi;
	if [ ! -f #{node[:libjs][:perl]}.tar.gz ]; then wget #{node[:libjs][:perlurl]}; fi;
	tar -zxf #{node[:libjs][:version]}.tar.gz
	tar -zxf #{node[:libjs][:perl]}.tar.gz
	cd js/src/ && make -f Makefile.ref && cd ../..
	mkdir -p #{node[:js_install_prefix]}/include/js/
	cp js/src/*.h #{node[:js_install_prefix]}/include/js/
	cp js/src/*.tbl #{node[:js_install_prefix]}/include/js/
	cp js/src/Linux_All_DBG.OBJ/*.so #{node[:js_install_prefix]}/lib/
	cp js/src/Linux_All_DBG.OBJ/*.a #{node[:js_install_prefix]}/lib/
	cd #{node[:libjs][:perl]} 
  perl Makefile.PL -E4X 
  make 
  make test 
  make install
	EOH
end

# ==== INSTALL LIBDBI ====
bash "install_libdbi" do
	user "root"
  code <<-EOH
    cd /tmp
    wget "#{node[:libdbi][:host]}/#{node[:libdbi][:version]}.tar.gz"
    tar -zxf #{node[:libdbi][:version]}.tar.gz
    cd "#{node[:libdbi][:version]}"
    ./configure --disable-docs
    make all install
	EOH
end

# ==== INSTALL LIBDBI DRIVERS =====
bash "install_libdbi_drivers" do
	user "root"
  code <<-EOH
    cd /tmp
    wget "#{node[:libdbi][:host]}/#{node[:libdbi][:drivers]}.tar.gz"
    tar -zxf #{node[:libdbi][:drivers]}.tar.gz
    cd "#{node[:libdbi][:drivers]}"
    ./configure  --disable-docs --with-pgsql --enable-libdbi 
    make all install 
	EOH
end


# LDCONFIG

template "/etc/ld.so.conf.d/eg.conf" do
    source "eg-ld.conf.erb"
    mode 0640
    owner "root"
    group "root"
end

execute "reloadldconf" do
	user "root"
	command "ldconfig"
end

#========= CORE EVERGREEN INSTALL ===========

subversion "Evergreen" do
  user "opensrf"
  group "opensrf"
  repository "#{node[:evergreen][:svnpath]}"
  destination "#{node[:evergreen][:folder]}"
  action :sync
end

bash "make_evergreen" do
  user "opensrf"
  code <<-EOH
  cd "#{node[:evergreen][:folder]}"
  ./autogen.sh
  echo "./configure --prefix=#{node[:evergreen][:prefix]} --sysconfdir=#{node[:evergreen][:sysconfdir]}" > test.txt
  ./configure --prefix=#{node[:evergreen][:prefix]} --sysconfdir=#{node[:evergreen][:sysconfdir]}
  make
  EOH
end

bash "install_evergreen" do
  user "root"
  code <<-EOH
    cd "#{node[:evergreen][:folder]}"
    make STAFF_CLIENT_BUILD_ID=#{node[:evergreen][:staff_client_build_id]} install
    cd "#{node[:evergreen][:localstatedir]}/web/xul"
    ln -sf #{node[:evergreen][:staff_client_build_id]}/server server
  EOH
end

# === MAKE SYMLINKS FOR STAFF CLIENT
node[:evergreen][:staff_client_symlinks].each do |s|
  bash "symlink_#{s}" do
    user "root"
   code <<-EOH
   cd "#{node[:evergreen][:localstatedir]}/web/xul"
   ln -sf #{node[:evergreen][:staff_client_build_id]} #{s}
   EOH
 end
end

# === DATABASE STUFF ===
if node[:evergreen][:buildlocaldb]
  package "postgresql"
  package "postgresql-contrib-8.4"
  package "postgresql-plperl-8.4"
  package "postgresql-server-dev-8.4"

  bash "wipedb" do
    user "postgres"
    group "postgres"
    code <<-EOH
      psql -c 'DROP DATABASE IF EXISTS #{node[:evergreen][:dbname]}'
      psql -c 'DROP ROLE IF EXISTS #{node[:evergreen][:dbuser]}'
    EOH
  end
 
  bash "createdb" do
    user "postgres"
    group "postgres"
    code <<-EOH
      createdb -T template1 -E UNICODE #{node[:evergreen][:dbname]}
      createlang plperl #{node[:evergreen][:dbname]}
      createlang plperlu #{node[:evergreen][:dbname]}
      createlang plpgsql #{node[:evergreen][:dbname]}
      psql -f /usr/share/postgresql/8.4/contrib/tablefunc.sql #{node[:evergreen][:dbname]}
      psql -f /usr/share/postgresql/8.4/contrib/tsearch2.sql #{node[:evergreen][:dbname]}
      psql -f /usr/share/postgresql/8.4/contrib/pgxml.sql #{node[:evergreen][:dbname]}
      psql #{node[:evergreen][:dbname]} -c "CREATE ROLE #{node[:evergreen][:dbuser]} PASSWORD '#{node[:evergreen][:dbpw]}' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;"    
    EOH
  end
  
  bash "eg-createdb" do
    user "opensrf"
    group "opensrf"
    code <<-EOH
      cd "#{node[:evergreen][:folder]}"
      perl Open-ILS/src/support-scripts/eg_db_config.pl --update-config \
       --service all --create-schema --create-bootstrap --create-offline \
       --user #{node[:evergreen][:dbuser]} --password #{node[:evergreen][:dbpw]} --hostname #{node[:evergreen][:dbhost]} --port #{node[:evergreen][:dbport]} \
       --database #{node[:evergreen][:dbname]}
    EOH
  end

end



# ==== XML AND APACHE CONFIG FILES
template "#{node[:evergreen][:sysconfdir]}/opensrf.xml" do
    source "opensrf.xml.erb"
    mode 0600
    owner "opensrf"
    group "opensrf"
end

template "#{node[:evergreen][:sysconfdir]}/opensrf_core.xml" do
    source "opensrf_core.xml.erb"
    mode 0600
    owner "opensrf"
    group "opensrf"
end

template "#{node[:evergreen][:sysconfdir]}/oils_web.xml" do
    source "oils_web.xml.erb"
    mode 0600
    owner "opensrf"
    group "opensrf"
end

template "/etc/apache2/sites-available/eg.conf" do
  source "eg.conf.erb"
  owner "opensrf"
  group "opensrf"
end

template "/etc/apache2/eg_vhost.conf" do
  source "eg_vhost.conf.erb"
  mode 0660
  owner "opensrf"
  group "opensrf"
end

template "/etc/apache2/startup.pl" do
  source "startup.pl.erb"
  mode 0660
  owner "opensrf"
  group "opensrf"
end



# ==== MISC FUMBLING ABOUT

bash "mkdir_lock" do
  user "opensrf"
  code <<-EOH
    mkdir -p /openils/var/run
    mkdir -p /openils/var/lock
  EOH
end

execute "fixkarmicmemcache" do
  user "root"
  command "echo 'ENABLE_MEMCACHED=yes' > /etc/default/memcached"
  notifies :restart, resources(:service => "memcached"), :immediately
end

bash "fixowners" do
  user "root"
  code <<-EOH
    chown -R opensrf:opensrf #{node[:evergreen][:prefix]}
  EOH
end


# ==== OPENSRF USER ENV SETTINGS
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




