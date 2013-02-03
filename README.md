# Description
beta

Sets up a liquid democracy tool: LiquidFeedback  (http://liquidfeedback.org)

Based on Lua and Postgresql

# Requirements
Cookbooks
```
postgresql and database
mercurial
openssl
```

# Resources

**Instance related attributes**
```ruby
liquid_feedback "OurOrganization" do
    email_from "lqfb@example.com"
    area "The Internet"
    action :create
    member_ttl '1 year'

    # software related attributes
    core_version 'v2.1.0'
    webmcp_version 'v2.1.0'
    frontend_version 'v2.1.2'
end
```

# Usage

## Via Resource (multi-instance)
Set up one or multiple liquid_feedback resource in your recipe and run it.
Your admin invitekey will be written to a template

### miminal example script
```ruby
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless['lf']['db_password'] = secure_password
node.set['lf']['db_user'] = "liquid_feedback"

liquid_feedback "org1" do

    email "org1.example.com"
    locale "de_DE.UTF-8"

    db_user node['lf']['db_user']
    db_password node['lf']['db_password']

    action [:create, :start]
end

liquid_feedback "org2" do

    email "org2@example.com"
    locale "en_US.UTF-8"

    db_user node['lf']['db_user']
    db_password node['lf']['db_password']

    action [:create, :start]
end
```


## Via Recipe (single-instance)

Set up node attributes
Include recipe.

Your admin invitekey will be stored as node attribute
```ruby 
node['lf']['admin_invitecode']
```

# Notes

If you use chef-solo, you must set lf db password and postgresql password in
node json directly:

```json
    "lf": {
        "db": {
            "password": "passwordForLQInstanceUser"
        }
    },
    "postgresql": {
        "password": {
            "postgres": "passwordForConncetingToPG"
        }
    }
```

KNOWN BUGS with using resources:
- Lighttpd currently supports only single-instance (web path)
- Postgresql supports only one db_user and db_password (pg_hba needs to be setup for all users, circumvent with setting db_user and db_password same on all your resources)

# Ideas/Todo
- Setup Postfix or exim (or email)
- Send event notifications

- Set up Unix users for postges access
- Set up lighttp to run lua scripts as unix users (and find out which access rights they need)

# Contact
see metadata.rb
