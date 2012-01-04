# Fat Free CRM

[![TravisCI][travis-img]][travis-ci] [![Dependency Status][gemnasium-img]][gemnasium]

[travis-img]: https://secure.travis-ci.org/fatfreecrm/fat_free_crm.png?branch=master
[travis-ci]: http://travis-ci.org/fatfreecrm/fat_free_crm
[gemnasium-img]: https://gemnasium.com/fatfreecrm/fat_free_crm.png?travis
[gemnasium]: https://gemnasium.com/fatfreecrm/fat_free_crm

### An open source, Ruby on Rails [customer relationship management][crm-wiki] platform (CRM).

[crm-wiki]: http://en.wikipedia.org/wiki/Customer_relationship_management

Out of the box it features group collaboration, campaign and lead management, contact lists, and opportunity tracking.

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

(Ruby on Rails v3 and other gem dependencies will be installed automatically by Bundler.)


### Downloads

* Git source code repository: git://github.com/fatfreecrm/fat_free_crm.git
* .zip or .tgz archives: http://github.com/fatfreecrm/fat_free_crm/downloads


### Upgrading from previous versions of Fat Free CRM

If you are upgrading from version 0.10.1 or below to the latest Rails 3.x version, your database schema
needs to be updated.

Please run the following commands in this order:

```bash
bundle install --without heroku   # Installs gem dependencies
rake crm:upgrade:schema           # Updates your schema to use the new timestamped migrations
rake db:migrate                   # Runs any new database migrations.
```

## Install on Heroku

You will need the heroku gem on your system.

```bash
gem install heroku
```

To set up Fat Free CRM on Heroku, run the following commands:

```bash
app_name="{{organization-crm}}" # <- Replace with your desired application name
cp config/settings.yml.example config/settings.yml
git add -f config/settings.yml
git commit -m "Added default settings.yml"
heroku create $app_name --stack cedar
git push heroku master
heroku run rake crm:setup USERNAME=admin PASSWORD=admin EMAIL=admin@example.com
heroku config:add HEROKU=true
```

## Install locally, or on a server

#### Set Up Configuration (Database & Settings)

Fat Free CRM supports PostGreSQL, MySQL and SQLite databases. The source code comes with
sample database configuration files, such as: <tt>config/database.mysql.yml</tt>
for MySQL and <tt>config/database.sqlite.yml</tt> for SQLite.

Based on your choice of database, create <tt>config/database.yml</tt>:

```bash
cp config/database.mysql.yml config/database.yml
```

* Edit <tt>config/database.yml</tt> and specify database names and authentication details.

* Then, edit your <tt>Gemfile</tt> and uncomment only your chosen database.


#### Install Gem Dependencies

After you have uncommented the right database adapter in your <tt>Gemfile</tt>,
run the following command from the application's root directory:

```bash
bundle install --without heroku
```

#### Create Database

Now you are ready to create the database:

```bash
rake db:create
```

#### Set Up Application

The next step is to load default Fat Free CRM settings, such as menu structures,
default colors, etc. and create the Admin user.

Using the provided sample, create your <tt>config/settings.yml</tt>:

```bash
cp config/settings.yml.example config/settings.yml
```

* Edit <tt>config/settings.yml</tt> and configure any required settings, such as your host, base URL and language (locale).


Next, run the following rake task:

```bash
rake crm:setup
```

The previous command will prompt you for an admin user, password and email.
If you want to run this task without any user input, you can set the following variables:

```bash
rake crm:setup USERNAME=admin PASSWORD=password EMAIL=admin@example.com
```

#### Load Demo Data (Optional)

You can test drive Fat Free CRM by loading sample records that are generated
on the fly mimic the actual use.

**IMPORTANT**: Loading demo will delete all existing data from your database.

```bash
rake crm:demo:load
```

Among other things the demo generator creates 8 sample user records with the
following usernames: <tt>aaron</tt>, <tt>ben</tt>, <tt>cindy</tt>, <tt>dan</tt>,
<tt>elizabeth</tt>, <tt>frank</tt>, <tt>george</tt>, and <tt>heather</tt>.
You can log in with any of these names using the name as password.
The demo site at http://demo.fatfreecrm.com provides access as a sample user as well.

You can reset the database and reload demo data at any time by using:

```bash
rake crm:demo:reload
```

#### Run the App

Now you should be able to launch the Rails server and point your web browser
to http://localhost:3000

```bash
rails server
```

# Resources

|||
|-----------------------------------:|:--------------------------|
|                 **Home page**: | http://www.fatfreecrm.com |
|               **Online demo**: | http://demo.fatfreecrm.com |
|              **Project page**: | http://github.com/michaeldv/fat_free_crm/tree/master |
|         **Features and bugs**: | http://fatfreecrm.lighthouseapp.com |
|    **Twitter commit updates**: | http://twitter.com/fatfreecrm |
|       **User's Google group**: | http://groups.google.com/group/fat-free-crm-users |
|  **Developer's Google group**: | http://groups.google.com/group/fat-free-crm-dev |
|               **IRC channel**: | [#fatfreecrm](http://webchat.freenode.net/) on irc.freenode.net |


# For Developers

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

