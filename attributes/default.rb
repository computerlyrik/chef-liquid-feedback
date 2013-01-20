
default['lf']['basedir'] = "/opt"




default['lf']['organisation'] = "MyOrganisation"
default['lf']['area'] =  "Default Area"
default['lf']['member_ttl'] =  "1 year"
default['lf']['contingent'] =  Hash.new

default['lf']['email_from'] = "lf@#{node['domain']}"
default['lf']['email_to'] = "lf@#{node['domain']}"

default['lf']['core_repo'] = "http://www.public-software-group.org/mercurial/liquid_feedback_core"
default['lf']['core_version'] = "v2.1.0"

default['lf']['frontend_repo'] = "http://www.public-software-group.org/mercurial/liquid_feedback_frontend"
default['lf']['frontend_version'] = "v2.1.3"

default['lf']['webcmp_version'] = "v1.2.5"



#will be set by recipe if unset
default['lf']['db_user']    = nil
default['lf']['db_name']    = nil
default['lf']['db_password']= nil
