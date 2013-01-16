#
# Cookbook Name:: liquid-feedback
# Provider:: default
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


include Opscode::OpenSSL::Password
include Chef::Mixin::LanguageIncludeRecipe

action :create do
  include_recipe "mercurial"
  directory node['lf']['basedir']
  #########################################################################
  ########################### BACKEND ####################################
  #########################################################################

  db_user = "lf_#{@new_resource.organisation}"
  db_name = db_user
  db_password = secure_password
  lf_dir = "#{node['lf']['basedir']}/#{@new_resource.organisation}"
  directory lf_dir
  
  ######### Checkout core code
  mercurial "#{lf_dir}/liquid_feedback_core" do
    repository new_resource.core_repo
    if new_resource.core_version
      reference new_resource.core_version
    end
    action :sync
  end

  ########## Set up Postgre SQL Database

  #needed to auth with liquid_feedback user
  #TODO SPLIT HBA FILES TO FLEXIBLE CONFIGURE
  node.set['postgresql']['pg_hba'] = [
    {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
    {:type => 'local', :db => db_user, :user => db_user, :addr => nil, :method => 'password'},
    {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
    {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
  ]
  include_recipe "postgresql::server"
  include_recipe "database::postgresql"

  postgresql_connection_info = {:host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']}

  postgresql_database_user db_user do
    connection postgresql_connection_info
    password db_password ##TODO CHECK IF WORKING
  #  privileges [:select,:update,:insert]
    action :create
  end

  postgresql_database db_name do
    connection postgresql_connection_info
    owner db_user
    action :create
  end

  postgresql_database 'db_lang' do
    connection postgresql_connection_info
    database_name db_name
    sql "CREATE LANGUAGE plpgsql"
    action :nothing
    ignore_failure true
    subscribes :query, resources(:postgresql_database => db_name), :immediately
  end

  execute "db_import" do
    command "psql -v ON_ERROR_STOP=1 -f core.sql #{db_name} #{db_user}"
    cwd "#{lf_dir}/liquid_feedback_core"
    environment ({'PGPASSWORD' => db_password})
    action :nothing
    subscribes :run, resources(:postgresql_database => db_name), :immediately
  end
  
  invite_code = secure_password
  template "#{lf_dir}/invitecode" do
    action :nothing
    subscribes :create, resources(:execute => 'db_import')
    variables ({:code => invite_code})
  end

  postgresql_database "db_setup" do
    connection postgresql_connection_info
    database_name db_name
    sql <<-EOH
      INSERT INTO system_setting (member_ttl) VALUES ('#{new_resource.member_ttl}');
      INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 hour', 20, 6);
      INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 day', 80, 12);
      INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 hour', 200, 60);
      INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 day', 800, 120);
      INSERT INTO policy (index, name, admission_time, discussion_time, verification_time, voting_time, issue_quorum_num, issue_quorum_den, initiative_quorum_num, initiative_quorum_den) VALUES (1, 'Default policy', '8 days', '15 days', '8 days', '15 days', 10, 100, 10, 100);
      INSERT INTO unit (name) VALUES ('#{new_resource.organisation}');
      INSERT INTO area (unit_id, name) VALUES (1, '#{new_resource.area}');
      INSERT INTO allowed_policy (area_id, policy_id, default_policy) VALUES (1, 1, TRUE);
      INSERT INTO member (login, name, admin, invite_code) VALUES ('admin', 'Administrator', TRUE, '#{invite_code}');
    EOH
    action :nothing
    subscribes :query, resources(:execute => 'db_import')
  end


  #%w{imagemagick}.each do | p | 
  #  package p
  #end


  #########################################################################
  ########################### FRONTEND ####################################
  #########################################################################





  ######## Install WebMCP: 
  ######### Checkout core code
  mercurial "#{lf_dir}/webmcp-install" do
    repository "http://www.public-software-group.org/mercurial/webmcp"
    if new_resource.webcmp_version
      reference new_resource.webcmp_version
    end
    action :sync
  end

  package "lua5.1"
  package "liblua5.1-0-dev"
  execute 'make CC="cc -I /usr/include/lua5.1"' do
    cwd "#{lf_dir}/webmcp-install"
  #  action :nothing
  #  subscribes :run, resources(:mercurial => "/root/install/webmcp")
  end

  directory "#{lf_dir}/webmcp"
  execute "cp -RL #{lf_dir}/webmcp-install/framework/* #{lf_dir}/webmcp/"
  #  action :nothing
  #  subscribes :run, resources(:mercurial => "/root/install/webmcp")

  ######## Install RocketWiki LqFb-Edition: 
  directory "/root/install"
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

  directory "#{lf_dir}/rocketwiki-lqfb"

  execute "cp rocketwiki-lqfb rocketwiki-lqfb-compat #{lf_dir}/rocketwiki-lqfb/" do
    cwd "/root/install/rocketwiki-lqfb-v0.4/"
  end


  ######### Checkout Frontend code
  mercurial "#{lf_dir}/liquid_feedback_frontend" do
    repository new_resource.frontend_repo
    if new_resource.frontend_version
      reference new_resource.frontend_version
    end
    action :sync
  end

  execute "compile_locales" do
    command "/usr/bin/make"
    cwd "#{lf_dir}/liquid_feedback_frontend/locale"
    environment ({
      'PATH' => "#{lf_dir}/rocketwiki-lqfb:$PATH",
      'LC_ALL' => 'de_DE.UTF-8',
      'LANG' => 'de_DE.UTF-8'})
  end


  directory "#{lf_dir}/liquid_feedback_frontend/tmp" do
    owner "www-data"
    recursive true
  end

  template "#{lf_dir}/liquid_feedback_frontend/config/myconfig.lua" do
    mode 0644
  end


  #COMPILE GETPIC for fastpath delivering images (unused at moment)
  execute 'make CC="-D GETPIC_DEFAULT_AVATAR=#{lf_dir}/liquid_feedback_frontend/static/avatar.jpg"' do
    cwd "#{lf_dir}/liquid_feedback_frontend/fastpath"
  end
  
  package "sendmail"

  ######## Configure lighty
  package "lighttpd"
  service "lighttpd"
  template "/etc/lighttpd/conf-available/60-liquidfeedback-#{@new_resource.organisation}.conf" do
    mode 0644
    notifies :restart, resources(:service => "lighttpd")
  end

  link "/etc/lighttpd/conf-enabled/60-liquidfeedback-#{@new_resource.organisation}.conf" do 
    to "/etc/lighttpd/conf-available/60-liquidfeedback-#{new_resource.organisation}.conf"
    notifies :restart, resources(:service => "lighttpd")
  end


  ######## Setup Update service
  template "#{lf_dir}/liquid_feedback_core/lf_updated"

  template "/etc/init.d/lf_updated_#{@new_resource.organisation}" do
    source "lf_updated.init.erb"
    mode 0755
  end

  #TODO sending event notifications
  #su - www-data
  #cd /opt/liquid_feedback_frontend/
  #echo "Event:send_notifications_loop()" | ../webmcp/bin/webmcp_shell myconfig

end

action :start do
  service "lf_updated_#{@new_resource.organisation}" do
    action [:enable, :start]
  end
end

action :disable do
  service "lighttpd"
  template "/etc/lighttpd/conf-enabled/60-liquidfeedback-#{@new_resource.organisation}.conf" do
    action :delete
    notifies :restart, resources(:service => "lighttpd")
  end
  service "lf_updated_#{@new_resource.organisation}" do
    action [:stop, :disable]
  end
end

