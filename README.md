# Fat Free CRM [![Code Climate][codeclimate-img-url]][codeclimate-url] [![Discord][discord-img-url]][discord-url]

[codeclimate-img-url]: https://codeclimate.com/github/fatfreecrm/fat_free_crm.svg
[codeclimate-url]: https://codeclimate.com/github/fatfreecrm/fat_free_crm
[discord-img-url]: https://img.shields.io/badge/chat-on%20discord-7289da.svg?sanitize=true
[discord-url]: https://discord.gg/JVrzD8RYyk

### An open source, Ruby on Rails [customer relationship management][crm-wiki] platform (CRM).

[crm-wiki]: http://en.wikipedia.org/wiki/Customer_relationship_management

Out of the box it features group collaboration, campaign and lead management, contact lists, and opportunity tracking.

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

Visit our website at [http://www.fatfreecrm.com/](http://www.fatfreecrm.com/)

## System Requirements

* Ruby 3.1+ recommended
* MySQL v4.1.1 or later (v5+ is recommended), SQLite v3.4 or later, or Postgres 8.4.8 or later.
* ImageMagick (optional, only needed if you would like to use avatars)

(Ruby on Rails and other gem dependencies will be installed automatically by Bundler.)

## Installation

Please view one of the following installation guides:

### [Setup Linux or Mac OS](http://guides.fatfreecrm.com/Setup-Linux-or-Mac-OS)

Installing Fat Free CRM on Linux or Mac OS X

### [Setup Heroku](http://guides.fatfreecrm.com/Setup-Heroku)

Setting up a Heroku instance for Fat Free CRM

### [Setup Microsoft Windows](http://guides.fatfreecrm.com/Setup-Microsoft-Windows)

Installing Fat Free CRM on Microsoft Windows

### [Running Fat Free CRM as a Rails Engine](http://guides.fatfreecrm.com/Running-as-a-Rails-Engine)

Run the Fat Free CRM gem within a separate Rails application.
This is the best way to deploy Fat Free CRM if you need to add plugins or make any customizations. Note that it is not yet simple to 'bolt' Fat Free CRM into your existing rails project, but we're heading in that direction.

### [Setup on Azure Virtual Machine](#setup-on-azure-virtual-machine)

Deploying Fat Free CRM on an Azure Virtual Machine.

## Upgrading from Previous Versions of Fat Free CRM

Please read the [Changelog](https://github.com/fatfreecrm/fat_free_crm/blob/master/CHANGELOG.md) document for more detailed information on upgrading from previous versions.

## Resources

|||
|-----------------------------------:|:--------------------------|
|                 **Home Page**: | [http://www.fatfreecrm.com](http://www.fatfreecrm.com) |
|                    **Guides**: | [http://guides.fatfreecrm.com](http://guides.fatfreecrm.com) |
|       **Github Project Page**: | [http://github.com/fatfreecrm/fat_free_crm](http://github.com/fatfreecrm/fat_free_crm) |
| **Feature Requests and Bugs**: | [http://support.fatfreecrm.com/](http://support.fatfreecrm.com/) |
|                  **RDoc API**: | [http://api.fatfreecrm.com](http://api.fatfreecrm.com) |
|                  **Ruby gem**: | [https://rubygems.org/gems/fat_free_crm](https://rubygems.org/gems/fat_free_crm) |
|    **Twitter Commit Updates**: | [http://twitter.com/fatfreecrm](http://twitter.com/fatfreecrm) |
|       **User's Google Group**: | [http://groups.google.com/group/fat-free-crm-users](http://groups.google.com/group/fat-free-crm-users) |
|  **Developer's Google Group**: | [http://groups.google.com/group/fat-free-crm-dev](http://groups.google.com/group/fat-free-crm-dev) |
|               **IRC Channel**: | [#fatfreecrm](http://webchat.freenode.net/) on irc.freenode.net |

## For Developers

Fat Free CRM is released under the MIT license and is freely available for you to use for your own purposes. We do encourage contributions to make Fat Free CRM even better. Send us a pull-request and we'll do our best to accommodate your needs.

Specific features that are not 'Fat Free' in nature, can be added by creating Rails Engines. See the [wiki](http://github.com/fatfreecrm/fat_free_crm/wiki) for information on how to do this.

Tests can easily be run by typing `rake` but please note that they do take a while to run!

## Main Contributors

* [Michael Dvorkin (@michaeldv)](https://github.com/michaeldv) - Founding creator
* CloCkWeRX
* johnnyshield
* DmitryAvramec
* steveyken

See the [contributors graph](https://github.com/fatfreecrm/fat_free_crm/graphs/contributors) and the [contributors file](https://github.com/fatfreecrm/fat_free_crm/blob/master/CONTRIBUTORS.md) for further details.

## License

Fat Free CRM  
Copyright (c) 2008-2018 Michael Dvorkin and contributors.

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
INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

### Steps to Deploy Fat Free CRM on Azure VM

#### 1. Connecting to the Virtual Machine

- Use Azure's built-in SSH connection functionality or connect directly using the VM's public IP address.
- Ensure the SSH key pair was configured during VM creation.

#### 2. Installing Docker on the VM

- Install `moby-engine` for Docker compatibility with the Azure-provided Ubuntu image:
  ```bash
  sudo apt-get update
  sudo apt-get install moby-engine moby-cli moby-buildx moby-compose
  sudo systemctl start moby
  sudo systemctl enable moby
  ```
  
#### 3. Setting Up an Apache Reverse Proxy Server

- Install and configure Apache to expose the application:
  ```bash
  sudo apt-get install apache2
  sudo a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests
  ```
  
- Configure the virtual host:
  ```apache
  <VirtualHost *:80>
    ServerName <YOUR_VM_IP_ADDRESS>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:3000/
    ProxyPassReverse / http://127.0.0.1:3000/
  </VirtualHost>
  ```
  
- Restart Apache:
  ```bash
  sudo systemctl restart apache2
  ```

#### 4. Loading Demo Data into the Database
- Populate the database with demo data:
  ```bash
  sudo docker exec -it fat_free_crm-web-1 bundle exec rails ffcrm:demo:load
  ```

#### 5. Sharing the VM with the Group
- Configure permissions in Azure's IAM for the following resource groups, granting necessary access:

	* FFCRMVM (the virtual machine)
	* FFCRMVM-ip (the public IP address)
	* FFCRMVM-nsg (the network security group)
	* FFCRMVM-vnet (the virtual network)
	* ffcrmvm454_z1 (the IP configuration)
	* FFCRMVM_key (the SSH key access)
- Share SSH keys with team members for coordinated access.

#### Additional Configuration for Azure App Service
- Update the docker-compose.yml file to check for an existing database before initializing:
  ```yaml
  command: >
    bash -c "/usr/local/bin/wait-for-it.sh db:5432 --
      DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:exists || bundle exec rake db:create &&
      DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:schema:load assets:precompile &&
      bundle exec rails s -b '0.0.0.0' -p ${PORT:-3000}"

### Setup Guide

The following commands are necessary to run Fat Free CRM on the Docker VM once you have established an SSH connection.

#### 1. Connect to the VM via SSH
   - Use your preferred SSH client or Azure's built-in SSH functionality.

#### 2. Navigate to the Project Directory
  ```bash
  cd fat_free_crm
  ```

#### 3. Start the Docker Project in the Background
  ```bash
  sudo docker compose up -d
  ```

#### 4. Load Demo Data into the Database
  ```bash
  sudo docker exec -it fat_free_crm-web-1 bundle exec rails ffcrm:demo:load
  ```

#### 5. Monitor Logs for Errors
  ```bash
  sudo docker compose logs -f
  ```
   
- Ensure there are no errors. If the logs show the application is running without issues, the setup is successful.

#### 6. Shut Down the Project
  ```bash
  sudo docker compose down
  sudo docker volume rm fat_free_crm_pgdata
  ```
  
- This stops the project and removes the associated databases. Note: This step is necessary because the docker-compose file prevents the project from running if a database already exists, indicating a bug in the original Fat Free CRM project.

### Additional Notes
SSH Key Management: Consider configuring the VM to use individual SSH keys for each team member to simplify access control.
Performance Testing: With the VM setup, performance testing can be conducted more effectively, despite the initial setup challenges.
Future Improvements: Automating the CI/CD pipeline and addressing the database initialization bug can further streamline the deployment process.
