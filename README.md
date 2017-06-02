# Fat Free CRM [![TravisCI][travis-img-url]][travis-ci-url]  [![Code Climate][codeclimate-img-url]][codeclimate-url]

[travis-img-url]: https://secure.travis-ci.org/fatfreecrm/fat_free_crm.svg?branch=master
[travis-ci-url]: https://travis-ci.org/fatfreecrm/fat_free_crm
[codeclimate-img-url]: https://codeclimate.com/github/fatfreecrm/fat_free_crm.svg
[codeclimate-url]: https://codeclimate.com/github/fatfreecrm/fat_free_crm

### An open source, Ruby on Rails [customer relationship management][crm-wiki] platform (CRM).

[crm-wiki]: http://en.wikipedia.org/wiki/Customer_relationship_management


Out of the box it features group collaboration, campaign and lead management,
contact lists, and opportunity tracking.

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/contact_create.png" target="_blank" title="Create Contacts">
        <img src="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/contact_create_t.png" alt="Create Contacts">
      </a>
      <br />
      <em>Contacts</em>
    </td>
    <td align="center">
      <a href="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/contact_opportunity.png" target="_blank" title="Manage Opportunities">
        <img src="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/contact_opportunity_t.png" alt="Manage Opportunities">
      </a>
      <br />
      <em>Opportunities</em>
    </td>
    <td align="center">
      <a href="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/account_edit.png" target="_blank" title="Edit Accounts">
        <img src="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/account_edit_t.png" alt="Edit Accounts">
      </a>
      <br />
      <em>Accounts</em>
    </td>
    <td align="center">
      <a href="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/task_create.png" target="_blank" title="Create Tasks">
        <img src="https://github.com/fatfreecrm/fatfreecrm.github.com/raw/master/images/task_create_t.png" alt="Create Tasks">
      </a>
      <br />
      <em>Tasks</em>
    </td>
  </tr>
</table>

Pull requests and bug reports are always welcome!

Visit our website at http://www.fatfreecrm.com/


## System Requirements

* Ruby 2.3+ recommended
* MySQL v4.1.1 or later (v5+ is recommended), SQLite v3.4 or later, or Postgres 8.4.8 or later.
* ImageMagick (optional, only needed if you would like to use avatars)

(Ruby on Rails and other gem dependencies will be installed automatically by Bundler.)


## Installation

Please view one of the following installation guides:

### [Setup Linux or Mac OS](http://guides.fatfreecrm.com/Setup-Linux-or-Mac-OS.html)

Installing Fat Free CRM on Linux or Mac OS X

### [Setup Heroku](http://guides.fatfreecrm.com/Setup-Heroku.html)

Setting up a Heroku instance for Fat Free CRM

### [Setup Microsoft Windows](http://guides.fatfreecrm.com/Setup-Microsoft-Windows.html)

Installing Fat Free CRM on Microsoft Windows

### [Running Fat Free CRM as a Rails Engine](http://guides.fatfreecrm.com/Running-as-a-Rails-Engine.html)

Run the Fat Free CRM gem within a separate Rails application.
This is the best way to deploy Fat Free CRM if you need to add plugins or make any customizations. Note that it is not yet simple to 'bolt' Fat Free CRM into your existing rails project, but we're heading in that direction.


## Upgrading from previous versions of Fat Free CRM

Please read the [Release Notes](https://github.com/fatfreecrm/fat_free_crm/blob/master/CHANGELOG) document for more detailed information on upgrading from previous versions.


## Resources

|||
|-----------------------------------:|:--------------------------|
|                 **Home Page**: | http://www.fatfreecrm.com |
|                    **Guides**: | http://guides.fatfreecrm.com |
|               **Online Demo**: | http://demo.fatfreecrm.com |
|       **Github Project Page**: | http://github.com/fatfreecrm/fat_free_crm |
| **Feature Requests and Bugs**: | http://support.fatfreecrm.com/ |
|                  **RDoc API**: | http://api.fatfreecrm.com |
|                  **Ruby gem**: | https://rubygems.org/gems/fat_free_crm |
|    **Twitter Commit Updates**: | http://twitter.com/fatfreecrm |
|       **User's Google Group**: | http://groups.google.com/group/fat-free-crm-users |
|  **Developer's Google Group**: | http://groups.google.com/group/fat-free-crm-dev |
|               **IRC Channel**: | [#fatfreecrm](http://webchat.freenode.net/) on irc.freenode.net |


## For Developers

Fat Free CRM is released under the MIT license and is freely available for you to use for your own purposes. We do encourage contributions to make Fat Free CRM even better. Send us a pull-request and we'll do our best to accommodate your needs.

Specific features that are not 'Fat Free' in nature, can be added by creating Rails Engines. See the [wiki](http://github.com/fatfreecrm/fat_free_crm/wiki) for information on how to do this.

Tests can easily be run by typing 'rake' but please note that they do take a while to run! Alternatively, you can see the test build status over at our [travis page](http://travis-ci.org/fatfreecrm/fat_free_crm)


## Main contributors

* [Michael Dvorkin (@michaeldv)](https://github.com/michaeldv) - Founding creator
* [Steve Kenworthy (@steveyken)](https://github.com/steveyken) - Maintainer
* [Nathan Broadbent (@ndbroadbent)](https://github.com/ndbroadbent)

See the [contributors graph](https://github.com/fatfreecrm/fat_free_crm/graphs/contributors) and the [contributors file](https://github.com/fatfreecrm/fat_free_crm/blob/master/CONTRIBUTORS) for further details.

## License

Fat Free CRM
Copyright (c) 2008-2014 Michael Dvorkin and contributors.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
