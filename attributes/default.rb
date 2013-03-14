
## node attributes do only need to be set in recipe mode

default['lf']['organisation'] = "OurOrganisation"
default['lf']['area'] =  "Default Area"

default['lf']['email'] = "lf@#{node['domain']}"
default['lf']['locale'] = "de_DE.UTF-8"

default['lf']['member_ttl'] =  "1 year"
default['lf']['contingent'] =  Hash.new
default['lf']['public_access'] =  "none"

# software related options 

default['lf']['basedir'] = "/opt"
default['lf']['core_repo'] = "http://www.public-software-group.org/mercurial/liquid_feedback_core"
default['lf']['core_version'] = "v2.1.0"
default['lf']['frontend_repo'] = "http://www.public-software-group.org/mercurial/liquid_feedback_frontend"
default['lf']['frontend_version'] = "v2.1.3"
default['lf']['webcmp_version'] = "v1.2.5"



#will be set by resource if unset
default['lf']['db_user']    = nil
default['lf']['db_name']    = nil
default['lf']['db_password']= nil

#install default mailing service
default['lf']['sendmail'] = false
#if lighttp should create aliases for different LqFb instances
default['lf']['lighttp_alias'] = false
