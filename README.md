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

# Contact
see metadata.rb
