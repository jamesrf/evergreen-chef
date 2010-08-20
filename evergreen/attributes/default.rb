include_attribute "opensrf"

set_unless[:evergreen][:version] = 'rel_1_6_1'

case node[:evergreen][:version]
  when "trunk"
    set_unless[:evergreen][:svnpath] = "svn://svn.open-ils.org/ILS/#{node[:evergreen][:version]}"
  else
    set_unless[:evergreen][:svnpath] = "svn://svn.open-ils.org/ILS/branches/#{node[:evergreen][:version]}"
end

set_unless[:evergreen][:staff_client_build_id] = 'rel_1_6_1_0'
set_unless[:evergreen][:staff_client_symlinks] = ['rel_1_6_1_0','rel_1_6_1_1','rel_1_6_1_2','rel_1_6_1_3']


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



