#
# Cookbook Name:: liquidfeedback
# Recipe:: core
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

######### Checkout core code
mercurial "/opt/liquid_feedback_core" do
  repository "http://www.public-software-group.org/mercurial/liquid_feedback_core"
  reference node['lq']['lq_core']
  action :sync
end


########## Set up Postgre SQL Database

#needed to auth with liquid_feedback user
node.set['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'liquid_feedback', :user => 'liquid_feedback', :addr => nil, :method => 'password'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]
include_recipe "postgresql::server"
include_recipe "database::postgresql"

postgresql_connection_info = {:host => "127.0.0.1", :port => 5432, :username => 'postgres', :password => node['postgresql']['password']['postgres']}

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['lq']['db']['password'] = secure_password
postgresql_database_user 'liquid_feedback' do
  connection postgresql_connection_info
  password node['lq']['db']['password']
#  privileges [:select,:update,:insert]
  action :create
end

postgresql_database 'liquid_feedback' do
  connection postgresql_connection_info
  owner "liquid_feedback"
  action :create
end

postgresql_database 'db_lang' do
  connection postgresql_connection_info
  database_name 'liquid_feedback'
  sql "CREATE LANGUAGE plpgsql"
  action :nothing
  subscribes :query, resources(:postgresql_database => 'liquid_feedback'), :immediately
end

execute "db_import" do
  command "psql -v ON_ERROR_STOP=1 -f core.sql liquid_feedback liquid_feedback"
  cwd "/opt/liquid_feedback_core"
  environment ({'PGPASSWORD' => node['lq']['db']['password']})
  action :nothing
  subscribes :run, resources(:postgresql_database => 'liquid_feedback'), :immediately
end

node.set_unless['lq']['admin_invitecode'] = secure_password
postgresql_database "db_setup" do
  connection postgresql_connection_info
  database_name 'liquid_feedback'
  sql <<-EOH
    INSERT INTO system_setting (member_ttl) VALUES ('#{node['lq']['member_ttl']}');
    INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 hour', 20, 6);
    INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 day', 80, 12);
    INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 hour', 200, 60);
    INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 day', 800, 120);
    INSERT INTO policy (index, name, admission_time, discussion_time, verification_time, voting_time, issue_quorum_num, issue_quorum_den, initiative_quorum_num, initiative_quorum_den) VALUES (1, 'Default policy', '8 days', '15 days', '8 days', '15 days', 10, 100, 10, 100);
    INSERT INTO unit (name) VALUES ('#{node['lq']['organisation']}');
    INSERT INTO area (unit_id, name) VALUES (1, '#{node['lq']['area']}');
    INSERT INTO allowed_policy (area_id, policy_id, default_policy) VALUES (1, 1, TRUE);
    INSERT INTO member (login, name, admin, invite_code) VALUES ('admin', 'Administrator', TRUE, '#{node['lq']['admin_invitecode']}');
  EOH
  action :nothing
  subscribes :query, resources(:execute => 'db_import')
end



#%w{imagemagick}.each do | p | 
#  package p
#end

