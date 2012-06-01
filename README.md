# Fat Free CRM [![TravisCI][travis-img-url]][travis-ci-url]

[travis-img-url]: https://secure.travis-ci.org/fatfreecrm/fat_free_crm.png?branch=master
[travis-ci-url]: http://travis-ci.org/fatfreecrm/fat_free_crm

### An open source, Ruby on Rails [customer relationship management][crm-wiki] platform (CRM).

[crm-wiki]: http://en.wikipedia.org/wiki/Customer_relationship_management


Out of the box it features group collaboration, campaign and lead management,
contact lists, and opportunity tracking.

<table>
  <tr>
    <td align="center">
      <a href="http://fatfreecrm.com/images/contact_create.png" target="_blank" title="Create Contacts">
        <img src="http://fatfreecrm.com/images/contact_create_t.png" alt="Create Contacts">
      </a>
      <br />
      <em>Contacts</em>
    </td>
    <td align="center">
      <a href="http://fatfreecrm.com/images/contact_opportunity.png" target="_blank" title="Manage Opportunities">
        <img src="http://fatfreecrm.com/images/contact_opportunity_t.png" alt="Manage Opportunities">
      </a>
      <br />
      <em>Opportunities</em>
    </td>
    <td align="center">
      <a href="http://fatfreecrm.com/images/account_edit.png" target="_blank" title="Edit Accounts">
        <img src="http://fatfreecrm.com/images/account_edit_t.png" alt="Edit Accounts">
      </a>
      <br />
      <em>Accounts</em>
    </td>
    <td align="center">
      <a href="http://fatfreecrm.com/images/task_create.png" target="_blank" title="Create Tasks">
        <img src="http://fatfreecrm.com/images/task_create_t.png" alt="Create Tasks">
      </a>
      <br />
      <em>Tasks</em>
    </td>
  </tr>
</table>

Active development started in November 2008.
New features, enhancements, and updates appear on regular basis.

Pull requests and bug reports are always welcome!


## System Requirements

* Ruby v1.8.7 or v1.9.2
* MySQL v4.1.1 or later (v5+ is recommended), SQLite v3.4 or later, or Postgres 8.4.8 or later.
* ImageMagick (optional, only needed if you would like to use avatars)

(Ruby on Rails and other gem dependencies will be installed automatically by Bundler.)


### Downloads

* Git source code repository: `git clone git://github.com/fatfreecrm/fat_free_crm.git`
* **.zip** or **.tgz** archives: http://github.com/fatfreecrm/fat_free_crm/downloads


## Installation

Please view one of the following installation guides:

### [Setup Linux or Mac OS](http://guides.fatfreecrm.com/Setup-Linux-or-Mac-OS.html)

Installing Fat Free CRM on Linux or Mac OS X

### [Setup Heroku](http://guides.fatfreecrm.com/Setup-Heroku.html)

Setting up a Heroku instance for Fat Free CRM

### [Setup Microsoft Windows](http://guides.fatfreecrm.com/Setup-Microsoft-Windows.html)

Installing Fat Free CRM on Microsoft Windows

### [Ubuntu Server Setup Script](http://guides.fatfreecrm.com/Ubuntu-Server-Setup-Script.html)

Run this bash script to quickly setup a Ubuntu server

### [Running Fat Free CRM as a Rails Engine](http://guides.fatfreecrm.com/Running-as-a-Rails-Engine.html)

Run the Fat Free CRM gem within a separate Rails application.
This is the best way to deploy Fat Free CRM if you need to add plugins or make any customizations.


## Upgrading from previous versions of Fat Free CRM

If you are upgrading from version 0.10.1 or below to the latest Rails 3.x version, your database schema
needs to be updated.

Please run the following commands in this order:

```bash
bundle install --without heroku   # Installs gem dependencies
rake ffcrm:upgrade:schema         # Updates your schema to use the new timestamped migrations
rake db:migrate                   # Runs any new database migrations.
```


## Resources

|||
|-----------------------------------:|:--------------------------|
|                 **Home Page**: | http://www.fatfreecrm.com |
|                    **Guides**: | http://guides.fatfreecrm.com |
|               **Online Demo**: | http://demo.fatfreecrm.com |
|       **Github Project Page**: | http://github.com/fatfreecrm/fat_free_crm |
| **Feature Requests and Bugs**: | http://support.fatfreecrm.com/ |
|                  **RDoc API**: | http://api.fatfreecrm.com |
|    **Twitter Commit Updates**: | http://twitter.com/fatfreecrm |
|       **User's Google Group**: | http://groups.google.com/group/fat-free-crm-users |
|  **Developer's Google Group**: | http://groups.google.com/group/fat-free-crm-dev |
|               **IRC Channel**: | [#fatfreecrm](http://webchat.freenode.net/) on irc.freenode.net |


## For Developers

Fat Free CRM can be customized by implementing callback hooks and extended by
creating Rails Engines plugins. Check out these sample repositories demonstrating
the concepts:

* http://github.com/michaeldv/crm_sample_plugin/tree/master
* http://github.com/michaeldv/crm_sample_tabs/tree/master
* http://github.com/michaeldv/crm_web_to_lead/tree/master
* http://github.com/michaeldv/crm_tags/tree/master


## License

Copyright (c) 2008-2011 by Michael Dvorkin. All rights reserved.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.

See LICENSE file for more details.

