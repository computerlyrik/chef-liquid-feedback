#
# Cookbook Name:: liquid_feedback
# Recipe:: frontend
#
# Copyright 2012, computerlyrik
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

include_recipe "liquid-feedback"

directory "/root/install"

######## Install WebMCP: 
mercurial "/root/install/webmcp" do
  repository "http://www.public-software-group.org/mercurial/webmcp"
  reference node['lq']['webmcp']
  action :sync
end

package "lua5.1"
package "liblua5.1-0-dev"
execute 'make CC="cc -I /usr/include/lua5.1"' do
  cwd "/root/install/webmcp"
#  action :nothing
#  subscribes :run, resources(:mercurial => "/root/install/webmcp")
end

directory "/opt/webmcp"
execute "cp -RL framework/* /opt/webmcp/" do
  cwd "/root/install/webmcp"
#  action :nothing
#  subscribes :run, resources(:mercurial => "/root/install/webmcp")
end

######## Install RocketWiki LqFb-Edition: 
package "ghc"
package "libghc6-parsec3-dev"
#if debian
package "wget"
script "compile_rocketwiki" do
  interpreter "bash"
  user "root"
  cwd "/root/install"
  code <<-EOH
  wget http://www.public-software-group.org/pub/projects/rocketwiki/liquid_feedback_edition/v0.4/rocketwiki-lqfb-v0.4.tar.gz
  tar -xvzf rocketwiki-lqfb-v0.4.tar.gz
  cd rocketwiki-lqfb-v0.4
  make
  EOH
end

directory "/opt/rocketwiki-lqfb"

execute "cp rocketwiki-lqfb rocketwiki-lqfb-compat /opt/rocketwiki-lqfb/" do
  cwd "/root/install/rocketwiki-lqfb-v0.4/"
end

######## Install LiquidFeedback-Frontend
mercurial "/opt/liquid_feedback_frontend" do
  repository "http://www.public-software-group.org/mercurial/liquid_feedback_frontend"
  reference node['lq']['lq_frontend']
  action :sync
end

#TODO still errors if not executed manually - but why? error on ghc?
execute "compile_locales" do
  command "/usr/bin/make"
  cwd "/opt/liquid_feedback_frontend/locale"
  environment ({
    'PATH' => '/opt/rocketwiki-lqfb:$PATH',
    'LC_ALL' => 'de_DE.UTF-8',
    'LANG' => 'de_DE.UTF-8'})
end


directory "/opt/liquid_feedback_frontend/tmp" do
  owner "www-data"
  recursive true
end

template "/opt/liquid_feedback_frontend/config/myconfig.lua" do
  mode 0644
end


#COMPILE GETPIC for fastpath delivering images (unused at moment)
execute 'make CC="-D GETPIC_DEFAULT_AVATAR=/opt/liquid_feedback_frontend/static/avatar.jpg"' do
  cwd "/opt/liquid_feedback_frontend/fastpath"
end
  
#TODO CONFIGURE EXIM/POSTFIX

######## Configure lighty
package "lighttpd"
service "lighttpd"
template "/etc/lighttpd/conf-available/60-liquidfeedback.conf" do
  mode 0644
  notifies :restart, resources(:service => "lighttpd")
end

link "/etc/lighttpd/conf-enabled/60-liquidfeedback.conf" do 
  to "/etc/lighttpd/conf-available/60-liquidfeedback.conf"
  notifies :restart, resources(:service => "lighttpd")
end


######## Setup Update service
template "/opt/liquid_feedback_core/lf_updated"

template "/etc/init.d/lf_updated" do
  source "lf_updated.init.erb"
  mode 0755
end
service "lf_updated" do
  action :enable
end

#TODO sending event notifications
#su - www-data
#cd /opt/liquid_feedback_frontend/
#echo "Event:send_notifications_loop()" | ../webmcp/bin/webmcp_shell myconfig

