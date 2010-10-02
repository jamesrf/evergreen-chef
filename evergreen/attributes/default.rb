include_attribute "opensrf"

default[:evergreen][:version] = "rel_2_0"

case "#{node[:evergreen][:version]}"
  when "trunk"
    default[:evergreen][:svnpath] = "svn://svn.open-ils.org/ILS/#{node[:evergreen][:version]}"
  else
    default[:evergreen][:svnpath] = "svn://svn.open-ils.org/ILS/branches/#{node[:evergreen][:version]}"
end

set[:evergreen][:folder] = "/home/opensrf/Evergreen-#{node[:evergreen][:version]}"

default[:evergreen][:staff_client_build_id] = "#{node[:evergreen][:version]}"
default[:evergreen][:staff_client_symlinks] = ['rel_2_0_1','rel_2_0_2']

# == DB CONFIG

set_unless[:evergreen][:buildlocaldb] = true

set_unless[:evergreen][:dbuser] = 'evergreen'
set_unless[:evergreen][:dbpw] = 'egpass'
set_unless[:evergreen][:dbname] = 'evergreen'
set_unless[:evergreen][:dbhost] = 'localhost'
set_unless[:evergreen][:dbport] = '5432'

set_unless[:evergreen][:prefix] = "#{node[:opensrf][:prefix]}"
set_unless[:evergreen][:sysconfdir] = "#{node[:evergreen][:prefix]}/conf"
set_unless[:evergreen][:libdir] = "#{node[:evergreen][:prefix]}/lib"
set_unless[:evergreen][:localstatedir] = "#{node[:evergreen][:prefix]}/var"

# == PREREQ CONFIG
set[:libjs][:version] = 'js-1.7.0'
set[:libjs][:perl] = 'JavaScript-SpiderMonkey-0.19'
set[:libjs][:url] = "ftp://ftp.mozilla.org/pub/mozilla.org/js/#{node[:libjs][:version]}.tar.gz"
set[:libjs][:perlurl] = "ftp://mirror.datapipe.net/pub/CPAN/authors/id/T/TB/TBUSCH/#{node[:libjs][:perl]}.tar.gz"
set[:js_install_prefix] = '/usr/'

set[:libdbi][:version] = 'libdbi-0.8.3'
set[:libdbi][:drivers] = "libdbi-drivers-0.8.3"
set[:libdbi][:host] = "http://open-ils.org/~denials/evergreen"



