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
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless['lf']['db_password'] = secure_password

if node['lf']['sendmail']
  package 'sendmail'
end

liquid_feedback node['lf']['organisation'] do
    area node['lf']['area']

    email node['lf']['email']
    locale node['lf']['locale']
    
    member_ttl node['lf']['member_ttl']
    public_access node['lf']['public_access']

    # software related attributes

    basedir node['lf']['basedir']
    core_repo node['lf']['core_repo']
    core_version node['lf']['core_version']
    frontend_repo node['lf']['frontend_repo']
    frontend_version node['lf']['frontend_version']
    webmcp_version node['lf']['webcmp_version']

    lighttp_alias node['lf']['lighttp_alias']

    db_user node['lf']['db_user']
    db_name node['lf']['db_name']
    db_password node['lf']['db_password']

    action :create
end
