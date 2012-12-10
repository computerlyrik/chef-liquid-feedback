Description
===========
beta

Sets up a liquid democracy tool: LiquidFeedback

Based on Lua and Postgresql

Requirements
============

postgresql and database cookbooks
mercurial
openssl

Attributes
==========

Set up local attributes
node['lq']['organisation'] = "Our Organisation"
node['lq']['area'] = "Default Area"
node['lq']['member_ttl'] = "1 year"

Set up software version attributes
node['lq']['lq_core'] = "v2.1.0"
node['lq']['webmcp'] = "v1.2.5"
node['lq']['lq_frontend'] = "v2.1.2"

Usage
=====

Set up some Attributes if you like.
Just run recipe.
Your admin invitekey will be set as node attribute node['lq']['admin_invitecode']


Ideas/Todo
=========

- Setup Postfix or exim (or email)
- Send event notifications
