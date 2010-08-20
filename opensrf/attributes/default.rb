set_unless[:opensrf][:sysconfdir] = '/openils/conf'
set_unless[:opensrf][:prefix] = '/openils'
set_unless[:opensrf][:localstatedir] = '/openils/var'
set_unless[:opensrf][:libdir] = '/openils/lib'


set_unless[:opensrf][:version] = 'rel_1_4'

set_unless[:opensrf][:svnrepo] = "svn://svn.open-ils.org/OpenSRF/branches/#{node[:opensrf][:version]}"

case node[:opensrf][:version]
  when "trunk"
    set_unless[:opensrf][:svnrepo] = 'svn://svn.open-ils.org/OpenSRF/trunk'
end

set_unless[:opensrf][:folder] = "/home/opensrf/opensrf_#{node[:opensrf][:version]}"

set_unless[:opensrf][:public][:router][:username] = 'router'
set_unless[:opensrf][:public][:router][:password] = 'password'
set_unless[:opensrf][:public][:gateway][:username] = 'opensrf'
set_unless[:opensrf][:public][:gateway][:password] = 'password'
set_unless[:opensrf][:private][:router][:username] = 'router'
set_unless[:opensrf][:private][:router][:password] = 'password'
set_unless[:opensrf][:private][:gateway][:username] = 'opensrf'
set_unless[:opensrf][:private][:gateway][:password] = 'password'

override[:apache][:user] = "opensrf"