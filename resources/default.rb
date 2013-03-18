#
# Cookbook Name:: liquid-feedback
# Resource:: default
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

actions :create, :start, :disable

default_action :create
 
 
attribute :organisation, :kind_of => String, :name_attribute => true
attribute :area, :kind_of => String, :default => "Default Area"

attribute :email, :kind_of => String, :required => true
attribute :locale, :kind_of => String, :default =>  "en_US.UTF-8"

attribute :member_ttl, :kind_of => String, :default => "1 year"
attribute :contingent ,:kind_of => Hash
attribute :public_access ,:kind_of => String, :default => "none"

attribute :basedir, :kind_of => String, :default =>  "/opt"
attribute :core_repo, :kind_of => String, :default => "http://www.public-software-group.org/mercurial/liquid_feedback_core"
attribute :core_version, :kind_of => String, :default => "v2.1.0"
attribute :frontend_repo, :kind_of => String, :default => "http://www.public-software-group.org/mercurial/liquid_feedback_frontend"
attribute :frontend_version, :kind_of => String, :default => "v2.1.3"
attribute :webmcp_version, :kind_of => String, :default =>  "v1.2.5"

attribute :lighttp_alias, :kind_of => [TrueClass, FalseClass], :default =>  true

attribute :db_user, :kind_of => String
attribute :db_name, :kind_of => String
attribute :db_password, :kind_of => String

