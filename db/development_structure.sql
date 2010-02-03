CREATE TABLE `account_contacts` (
  `id` int(11) NOT NULL auto_increment,
  `account_id` int(11) default NULL,
  `contact_id` int(11) default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `account_opportunities` (
  `id` int(11) NOT NULL auto_increment,
  `account_id` int(11) default NULL,
  `opportunity_id` int(11) default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `assigned_to` int(11) default NULL,
  `name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `access` varchar(8) collate utf8_unicode_ci default 'Private',
  `website` varchar(64) collate utf8_unicode_ci default NULL,
  `toll_free_phone` varchar(32) collate utf8_unicode_ci default NULL,
  `phone` varchar(32) collate utf8_unicode_ci default NULL,
  `fax` varchar(32) collate utf8_unicode_ci default NULL,
  `billing_address` varchar(255) collate utf8_unicode_ci default NULL,
  `shipping_address` varchar(255) collate utf8_unicode_ci default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `email` varchar(64) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_accounts_on_user_id_and_name_and_deleted_at` (`user_id`,`name`,`deleted_at`),
  KEY `index_accounts_on_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=1404 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `activities` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `subject_id` int(11) default NULL,
  `subject_type` varchar(255) collate utf8_unicode_ci default NULL,
  `action` varchar(32) collate utf8_unicode_ci default 'created',
  `info` varchar(255) collate utf8_unicode_ci default '',
  `private` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_activities_on_user_id` (`user_id`),
  KEY `index_activities_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=9323 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `avatars` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `entity_id` int(11) default NULL,
  `entity_type` varchar(255) collate utf8_unicode_ci default NULL,
  `image_file_size` int(11) default NULL,
  `image_file_name` varchar(255) collate utf8_unicode_ci default NULL,
  `image_content_type` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `assigned_to` int(11) default NULL,
  `name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `access` varchar(8) collate utf8_unicode_ci default 'Private',
  `status` varchar(64) collate utf8_unicode_ci default NULL,
  `budget` decimal(12,2) default NULL,
  `target_leads` int(11) default NULL,
  `target_conversion` float default NULL,
  `target_revenue` decimal(12,2) default NULL,
  `leads_count` int(11) default NULL,
  `opportunities_count` int(11) default NULL,
  `revenue` decimal(12,2) default NULL,
  `starts_on` date default NULL,
  `ends_on` date default NULL,
  `objectives` text collate utf8_unicode_ci,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_campaigns_on_user_id_and_name_and_deleted_at` (`user_id`,`name`,`deleted_at`),
  KEY `index_campaigns_on_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=1611 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `commentable_id` int(11) default NULL,
  `commentable_type` varchar(255) collate utf8_unicode_ci default NULL,
  `private` tinyint(1) default NULL,
  `title` varchar(255) collate utf8_unicode_ci default '',
  `comment` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=432 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contact_opportunities` (
  `id` int(11) NOT NULL auto_increment,
  `contact_id` int(11) default NULL,
  `opportunity_id` int(11) default NULL,
  `role` varchar(32) collate utf8_unicode_ci default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `lead_id` int(11) default NULL,
  `assigned_to` int(11) default NULL,
  `reports_to` int(11) default NULL,
  `first_name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `last_name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `access` varchar(8) collate utf8_unicode_ci default 'Private',
  `title` varchar(64) collate utf8_unicode_ci default NULL,
  `department` varchar(64) collate utf8_unicode_ci default NULL,
  `source` varchar(32) collate utf8_unicode_ci default NULL,
  `email` varchar(64) collate utf8_unicode_ci default NULL,
  `alt_email` varchar(64) collate utf8_unicode_ci default NULL,
  `phone` varchar(32) collate utf8_unicode_ci default NULL,
  `mobile` varchar(32) collate utf8_unicode_ci default NULL,
  `fax` varchar(32) collate utf8_unicode_ci default NULL,
  `blog` varchar(128) collate utf8_unicode_ci default NULL,
  `linkedin` varchar(128) collate utf8_unicode_ci default NULL,
  `facebook` varchar(128) collate utf8_unicode_ci default NULL,
  `twitter` varchar(128) collate utf8_unicode_ci default NULL,
  `address` varchar(255) collate utf8_unicode_ci default NULL,
  `born_on` date default NULL,
  `do_not_call` tinyint(1) NOT NULL default '0',
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_contacts_on_user_id_and_last_name_and_deleted_at` (`user_id`,`last_name`,`deleted_at`),
  KEY `index_contacts_on_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=2267 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `leads` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `campaign_id` int(11) default NULL,
  `assigned_to` int(11) default NULL,
  `first_name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `last_name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `access` varchar(8) collate utf8_unicode_ci default 'Private',
  `title` varchar(64) collate utf8_unicode_ci default NULL,
  `company` varchar(64) collate utf8_unicode_ci default NULL,
  `source` varchar(32) collate utf8_unicode_ci default NULL,
  `status` varchar(32) collate utf8_unicode_ci default NULL,
  `referred_by` varchar(64) collate utf8_unicode_ci default NULL,
  `email` varchar(64) collate utf8_unicode_ci default NULL,
  `alt_email` varchar(64) collate utf8_unicode_ci default NULL,
  `phone` varchar(32) collate utf8_unicode_ci default NULL,
  `mobile` varchar(32) collate utf8_unicode_ci default NULL,
  `blog` varchar(128) collate utf8_unicode_ci default NULL,
  `linkedin` varchar(128) collate utf8_unicode_ci default NULL,
  `facebook` varchar(128) collate utf8_unicode_ci default NULL,
  `twitter` varchar(128) collate utf8_unicode_ci default NULL,
  `address` varchar(255) collate utf8_unicode_ci default NULL,
  `rating` int(11) NOT NULL default '0',
  `do_not_call` tinyint(1) NOT NULL default '0',
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_leads_on_user_id_and_last_name_and_deleted_at` (`user_id`,`last_name`,`deleted_at`),
  KEY `index_leads_on_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=838 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `opportunities` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `campaign_id` int(11) default NULL,
  `assigned_to` int(11) default NULL,
  `name` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `access` varchar(8) collate utf8_unicode_ci default 'Private',
  `source` varchar(32) collate utf8_unicode_ci default NULL,
  `stage` varchar(32) collate utf8_unicode_ci default NULL,
  `probability` int(11) default NULL,
  `amount` decimal(12,2) default NULL,
  `discount` decimal(12,2) default NULL,
  `closes_on` date default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_opportunities_on_user_id_and_name_and_deleted_at` (`user_id`,`name`,`deleted_at`),
  KEY `index_opportunities_on_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=1295 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `asset_id` int(11) default NULL,
  `asset_type` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_permissions_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `preferences` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `name` varchar(32) collate utf8_unicode_ci NOT NULL default '',
  `value` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_preferences_on_user_id_and_name` (`user_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) collate utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) collate utf8_unicode_ci NOT NULL,
  `data` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `settings` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(32) collate utf8_unicode_ci NOT NULL default '',
  `value` text collate utf8_unicode_ci,
  `default_value` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_settings_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `assigned_to` int(11) default NULL,
  `completed_by` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `asset_id` int(11) default NULL,
  `asset_type` varchar(255) collate utf8_unicode_ci default NULL,
  `priority` varchar(32) collate utf8_unicode_ci default NULL,
  `category` varchar(32) collate utf8_unicode_ci default NULL,
  `bucket` varchar(32) collate utf8_unicode_ci default NULL,
  `due_at` datetime default NULL,
  `completed_at` datetime default NULL,
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_tasks_on_user_id_and_name_and_deleted_at` (`user_id`,`name`,`deleted_at`),
  KEY `index_tasks_on_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=1022 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(32) collate utf8_unicode_ci NOT NULL default '',
  `email` varchar(64) collate utf8_unicode_ci NOT NULL default '',
  `first_name` varchar(32) collate utf8_unicode_ci default NULL,
  `last_name` varchar(32) collate utf8_unicode_ci default NULL,
  `title` varchar(64) collate utf8_unicode_ci default NULL,
  `company` varchar(64) collate utf8_unicode_ci default NULL,
  `alt_email` varchar(64) collate utf8_unicode_ci default NULL,
  `phone` varchar(32) collate utf8_unicode_ci default NULL,
  `mobile` varchar(32) collate utf8_unicode_ci default NULL,
  `aim` varchar(32) collate utf8_unicode_ci default NULL,
  `yahoo` varchar(32) collate utf8_unicode_ci default NULL,
  `google` varchar(32) collate utf8_unicode_ci default NULL,
  `skype` varchar(32) collate utf8_unicode_ci default NULL,
  `password_hash` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `password_salt` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `persistence_token` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `perishable_token` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `last_request_at` datetime default NULL,
  `last_login_at` datetime default NULL,
  `current_login_at` datetime default NULL,
  `last_login_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `current_login_ip` varchar(255) collate utf8_unicode_ci default NULL,
  `login_count` int(11) NOT NULL default '0',
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `admin` tinyint(1) NOT NULL default '0',
  `suspended_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_username_and_deleted_at` (`username`,`deleted_at`),
  KEY `index_users_on_email` (`email`),
  KEY `index_users_on_last_request_at` (`last_request_at`),
  KEY `index_users_on_remember_token` (`persistence_token`),
  KEY `index_users_on_perishable_token` (`perishable_token`)
) ENGINE=InnoDB AUTO_INCREMENT=6294 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');