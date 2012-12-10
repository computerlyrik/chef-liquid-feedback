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

# Attributes

**Set up instance attributes**
```ruby
node['lq']['organisation'] = "Our Organisation"
node['lq']['area'] = "Default Area"
node['lq']['member_ttl'] = "1 year"
```

**Customize software version attributes**
```ruby
node['lq']['lq_core'] = "v2.1.0"
node['lq']['webmcp'] = "v1.2.5"
node['lq']['lq_frontend'] = "v2.1.2"
```

# Usage
Set up the attributes you need.
Just run recipe.

Your admin invitekey will be set as node attribute 
```ruby 
node['lq']['admin_invitecode']
```


# Ideas/Todo
- Setup Postfix or exim (or email)
- Send event notifications
