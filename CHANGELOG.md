It does not matter how slowly you go as long as you do not stop.
-- Confucius

First they ignore you, then they laugh at you, then they fight you,
then you win. –- Mahatma Gandhi

Unreleased (0.18.0)
---------------------------------------------------------------------
### Important changes
#### Mininium ruby version
#665 Support for Ruby 2.3 has been dropped, with test coverage for 2.4 and 2.5 enabled.

#### Swap to FactoryBot
If you consume fat free crm as an engine and re-use any factories, you'll need to [upgrade to FactoryBot](https://github.com/thoughtbot/factory_bot/blob/4-9-0-stable/UPGRADE_FROM_FACTORY_GIRL.md).

#### Removed methods
`Lead.update_with_permissions` is removed, use user_ids and group_ids inside attributes instead and call lead.update_with_account_and_lead_counters
`FatFreeCRM::Permissions.save_with_permissions` is removed, use user_ids and group_ids inside attributes and call save
`FatFreeCRM::Permissions.update_with_permissions` is removed, use user_ids and group_ids inside attributes and call update_attributes

#### Other changes
TBA - https://github.com/fatfreecrm/fat_free_crm/milestone/6

Sat Jan 20, 2018 (0.17.1)
---------------------------------------------------------------------
 - #709 Revert accidental minimum ruby version 2.4 changes (#665)


Sat Jan 20, 2018 (0.17.0)
---------------------------------------------------------------------

### Important changes
#### Select2 for select boxes
This release replaces [Chozen](https://harvesthq.github.io/chosen/) with [Select2](https://select2.org/) consistently across the app.
This may break plugins which rely on Chozen. To fix any issues please
migrate to Select2 or add Chozen to your plugins.

#### Counter caches
To improve performance, a number of [counter caches](http://guides.rubyonrails.org/association_basics.html#options-for-belongs-to-counter-cache) have been added.

Users with large amounts of records may find certain [database migrations](https://github.com/fatfreecrm/fat_free_crm/blob/master/db/migrate/20180102075234_add_account_counter_caches.rb) taking a large amount of time, as each record is cached upfront.

#### Minimum ruby version is now Ruby 2.3
See #647 #654 Adopt min ruby version of 2.3.0 and apply safe navigiation rubocop rules

#### Other changes
 - #691 Wording
 - #688 Preparation for Devise
 - #686 Bundle update
 - #683 Rubocop: Refactoring
 - #680 Alternative build setup
 - #682 Rubocop: Hashrockets
 - #693 Update Japanese translations
 - #697 Minor security improvements
 - #703 #696 Replace Chozen with select2
 - #678 Find an account by name when name is in params (fixes #397) 
 - #673 Improve JS escaping 
 - #671 Devise Readiness (+ thread-safety): Refactor User.my scope 
 - #670 Fix #563 invalid default custom field minlength 
 - #668 Rubocop fixes for xls/rss builder classes 
 - #667 Rubocop: Autocorrect various assignment-if statements, case statements, etc. 
 - #666 Various rubocop corrected items 
 - #661 Bundle Update on 2018-01-06 
 - #655 Upgrade rubocop

 - #658 Upgrade Bootsnap gem, fixing an issue with windows

Sat Jan 6, 2018 (0.16.1)
---------------------------------------------------------------------
- #653 Fix regression with emails

Fri Jan 5, 2018 (0.16.0)
---------------------------------------------------------------------
- #633 Upgrade to rails 5.1.0
- #641 Swap default server from thin/unicorn to puma
- #631 Clean up locale files
- #612 DEPRECATION WARNING: #table_exists? currently checks both tables and views

Thu Dec 14, 2017 (0.15.0)
---------------------------------------------------------------------
This release upgrades to rails 5.0.0.

Be aware of https://github.com/rails/sprockets/issues/426 if you were using FFCRM as an engine.

 - #500 - Upgrade rails
 - #554 - Upgrade authlogic
 - #614 - Rails5 warnings
 - #643 Use FixtureSet instead of Fixtures module 
 - #642 Cleanup: Use Ruby style guide syntax for arrays
 - #640 Speed up builds with Bootsnap
 - #639 Code cleanup: Remove block-end comments (extracted from Rubocop PR) 
 - #637 Replace render :text with render :plain (Rails 5.1 prep) 
 - #636 Upgrade Migrations (preparation for Rails 5.1) 
 - #635 Fix alias_method_chain via @johnnyshields 
 - #632 Fix Travis CI chrome runs; Travis now requiring Chrome as an addon 
 - #628 Security Update on 2017-11-29 
 - #626 Use headless Chrome browser for feature testing 
 - #623 Fix license Rake task 
 - #617 Bundle Update on 2017-07-19 

Thu Feb 23, 2017 (0.15.0-beta.2)
---------------------------------------------------------------------
This release is aimed at minor updates and ruby 2.4 compatability via
the relevant rails updates.

Other improvements include:
  - #480 Improve select2 behaviour

Wed, Dec 7, 2016 (0.15.0-beta)
---------------------------------------------------------------------
This release is aimed at getting as many dependencies as possible up to date without significant refactoring.

 - Refactoring: Tests prefer build, build_record over ```FactoryGirl.create``` where possible
 - Refactoring: View tests minimize DB interaction greatly
 - Refactoring: ```@user.check_if_needs_approval``` must be explicitly called in rake tasks or similar, it is no longer a before_create hook
 - Refactoring: ```@user.destroyable?``` must be called in rake tasks or similar, it is no longer a before_destroy check
 - Various gem updates
 - Upgrade to Paperclip 5 (see https://github.com/thoughtbot/paperclip/wiki/Upgrade-Paperclip-4x-to-5x)
 - Upgrade to paper_trail 6+ (https://github.com/airblade/paper_trail/blob/master/CHANGELOG.md)

Mon, Dec 5, 2016 (0.14.0)
---------------------------------------------------------------------
- Various security fixes
- Enable CORS headers
- Ruby 2.0 or less dropped from CI


0.13.6 - February 12, 2015
---------------------------------------------------------------------
 - Fixes #413 and #414 - bold tag being escaped on user profile.
 - Fix for CVE-2015-1585 - CSRF vulnerability.

Full list:
https://github.com/fatfreecrm/fat_free_crm/compare/v0.13.5...v0.13.6

0.13.5 - January 22, 2015
---------------------------------------------------------------------
 - Update gems
 - Fixed #337 Added index on Versions created_at
 - [Security] Team section should not display opportunities current user is not allowed to see...
 - Update to rails 3.2.20
 - Fixed issue #347
 - Fixed issue #349
 - Fixed #351 - missing interpolation argument.
 - Fixed #353 - observes is a prototype function that is no longer used.
 - Fixed #283 - email max length is 254 according to IETF
 - Fix avatar issue in recent_activity
 - Merge pull request #354 
 - Fixed custom field handling of html entities.
 - Merge pull request #355
 - Fixed issue #374 - global lists missing from UK translation file.
 - Fix #356 - default SMTP session should have no auth


Full list:
https://github.com/fatfreecrm/fat_free_crm/compare/v0.13.4...v0.13.5

0.13.4 - September 4, 2014
---------------------------------------------------------------------
 - Fixed XSS vulnerability in helper method.
 - Use rails_autolink gem which contains updated XSS fixes.
 - Fixed XSS vulnerability if email data is manipulated.

Full list:
https://github.com/fatfreecrm/fat_free_crm/compare/v0.13.3...v0.13.4

0.13.3 - August 26, 2014
---------------------------------------------------------------------
 - Fixed bug where starts_on was being used instead of ends_on.      a0f69d7
 - fixes bug with toggling select/create account when converting lead      7c76b9c
 - Russian locale fixes. 
 - Add entity_observer to list of observers when running as an engine.
 - Allow notification emails to be sent from a particular address. Many 
 - Convert tag select box to Select2. We're deprecating Chosen
 - Enable fallback translations.
 - Fixed 'end of week' spec in tasks using Timecop.
 - Fixed bug with recent items box replacement.
 - #311 - problem with Thor being reference before it is loa
 - Fixed some bugs related to sorting custom fields.
 - #334 Added byebug for ruby2+.      5dca0ba
 - Update rails
 - Update gems
 - removes prototype-rails dependency
 - replaces prototype with jquery

Full list:
https://github.com/fatfreecrm/fat_free_crm/compare/v0.13.2...v0.13.3

0.13.2 - January 9, 2014
---------------------------------------------------------------------
 - Fixed issue with secret token not being saved if DB does not exist.
  
0.13.1 - January 7, 2014
---------------------------------------------------------------------
 - Lock down routes.
 - Remove stub hook
 - Remove unneccessary function
 - Don't spam gmail by default
 - consider_all_requests_local should be off by default in production mode
 - Remove pysch by default (optimise for ruby 2 now)
 - Fixed regular expression logic to be more sensitive to newline attacks.
 - users_controller requires security on its actions.
 - Send emails to file in development mode
 - Don't show user list if not logged in.
 - Remove old 'rake acceptance' task     2d4411a
 - Refactored secret token generation code
 - Hide password related attributes from the logs.
 - File syntax layout tweak.
 - Escape autocomplete output safely.
 - Locked down available views in Task.
 - sanitize list.url
 - Don't generate secret token in test mode.
 - Don't raise secret token generation error during tests.

Full list
https://github.com/fatfreecrm/fat_free_crm/compare/v0.13.0...v0.13.1

Fri Dec 27, 2013 (0.13.0)
---------------------------------------------------------------------
- Add user_id to lists table    
- Add campaign to opportunity advanced search.
- Add id to export formats. 
- Added ActiveSupport lazy load hooks for all models in Fat Free CRM.
- Added timeago library to enable future caching of search results. 
- Atom and RSS feeds now deal with cases where user doesn't exist.
- Better solution to internationalizing jquery.timeago plugin. 
- Configurationise the uniqueness constraint for account first names 
- Convert settings from syck to psych and remove dependency on Syck.
- Enforce available locales in latest version of I18n. 
- German translations
- Introducing client-side unobtrusive javascript for new comments.
- Peg paper_trail to v2.7
- Replaces rjs with erb/haml
- Updated to latest rails version

Bug fixes
- Ensure user isn't deleted if they still have tasks.
- Fix delete button not showing    
- Fix global list save problem     
- Closes #268: Replace the contents of "div#leads_pagination"
- #242 and #245. Fix cohsen_select helper to be able to
- Fixed issue #282
- Fixed issue with account categories inclusion matcher.
- Fixed issue with timeago plugin not precompiling. Resolves issue #286
- Fixed issue#281 - psych v2 is not supported.      
- Fixed one_submit_only js format and fixed red background highlight
- Fixed uninitialized constant 'Version' error on dashboard ATOM/RSS
- #270. Fixed procfile command for heroku. 
- #273 from notentered/testFixes      
- #279 from roadt/bugfix       
- #284 from roadt/bugfix   
- #287 from szetobo/fix_test_case   
- #288 from szetobo/update_scope     
- rake ffcrm:setup no longer nukes the database before starting.

Full changes:
https://github.com/fatfreecrm/fat_free_crm/compare/v0.12.3...v0.13.0


0.12.3 - January 9, 2014
---------------------------------------------------------------------
No changes

0.12.2 - January 7, 2014
---------------------------------------------------------------------
 - users_controller requires security on its actions.
 - Refactored secret token generation code to generate and persist a secret token in the DB if one doesn't exist
 - Don't show user list if not logged in.
 - Hide password related attributes from the logs.
 - consider_all_requests_local should be off by default in production mode
 - Fixed issue with secret token not being saved if DB does not exist. 


0.12.1 - December 27, 2013
---------------------------------------------------------------------
- Strengthen case to generate unique secret token.
- Ensure requests are protected.
- Add custom serializers for xml and json.
- Fixed sql injection in timeline method.
- Refactor activity_user to remove possible SQL injection points.
- Update gems to compile through

Fri, Jun 28, 2013 (0.12.0)
---------------------------------------------------------------------
- Ruby 1.9 support only (no ruby 1.8 and not yet ruby 2)
- Fixed version pagination bug thanks to reubenjs
- Can set default stage for opportunities
- First name can now be optional on leads, contacts and accounts (if desired)
- Number of search results is now displayed
- Fixed pagination ordering when displaying entities that belong to a master entity (e.g. opportunities inside a contact)
- Fixed tests
- Fixed avatar upload bug (by updating paperclip gem)
- Can now search for campaigns in opportunities advanced search
- Added ActiveSupport lazy load hooks for cleaner plugin integration
- Fixed bug where MS Smartquotes broke the dropbox (Thanks bitgangsta)
- Updated German translations (thanks Phillip Ullmann)
- Display relationship between contact and it's corresponding lead in the sidebar (thanks Phillip Ullmann)

Tue, Mar 16, 2013
---------------------------------------------------------------------
- Changed Fat Free CRM license to MIT, see MIT-LICENSE file.

Sat, Dec 29, 2012 (0.11.4)
---------------------------------------------------------------------
- Updated countries list
-   Please see an important fix for country data: https://github.com/fatfreecrm/fat_free_crm/wiki/The-Countries-Problem-and-How-to-Fix-It
- 0.11.4 will be the last ruby 1.8 release
- Comments can be added when items are created
- Dashboard shows assigned accounts and opportunities
- Now uses Rails 3.2
- Added Group tab in admin section
- Added jQuery datepicker
- Custom fields are now included in XLS export
- Updated Chinese translations
- Added Ransack / RansackUI search
- Added a Team tab to the interface
- Added ability to add new item views via plugins
-

Wed, May 9, 2012 (0.11.2)
---------------------------------------------------------------------
- Better html email parsing
- Users can subscribe to contacts/accounts etc
- Use CanCan for permissions
- Add jQuery UI
- German translation updates

Fri, Mar 30, 2012 (0.11.1)
---------------------------------------------------------------------
- Added Travis continuous integration service
- Rails 3 compatibility
- Added a few view hooks
- Dropbox now understands alt_email
- Updated translation file format
- Export includes full_name where applicable
- CSS bug fixes
- Swedish & Italian translations
- Controllers respond to JSON requests
- Several hundred other commits...

Tue, Sep 7, 2010
---------------------------------------------------------------------
- Added Gemfile and Gemfile.lock.
- Installed plugins.
- Merged with crossroads/rails3 fork; (runs 'rake crm:setup').

Mon, Sep 6, 2010
---------------------------------------------------------------------
- Generated empty Rails3 project.

Tue, Aug 31, 2010
---------------------------------------------------------------------
- Release 0.10.1.
- Updated CHANGELOG and CONTRIBUTORS files.

Sun, Aug 29, 2010
---------------------------------------------------------------------
- Added clickable labels to tasks sidebar checkboxes.

Thu, Aug 26, 2010
---------------------------------------------------------------------
- Added missing Polish translations (thanks, Kamil!)

Fri, Aug 20, 2010
---------------------------------------------------------------------
- Fixed deprecation warnings about plugins/**/tasks (thanks, Nathan!)
- Fixed Rails Engines deprecation warnings (thanks, Nathan!)
- [rake crm:setup] command now also runs plugin migrations (thanks, Nathan!)

Thu, Aug 19, 2010
---------------------------------------------------------------------
- Checkboxes now have clickable labels (thanks, Steve!)
- Load 'awesome_print' gem (if available) in development mode (thanks, Nathan!)

Wed, Aug 18, 2010
---------------------------------------------------------------------
- Added 'javascript_includes' hook (thanks, Nathan!)

Tue, Aug 17, 2010
---------------------------------------------------------------------
- Properly set the account value when attaching a contact to the account (closed LH #165)
- Fixed failing dropbox specs by rescuing proper exception (Rails 2.3.8).
- Added PrependEngineViews library module to let Fat Free CRM plugins override default views.

Mon, Aug 16, 2010
---------------------------------------------------------------------
- Minor UI tweaks.

Sat, Aug 14, 2010
---------------------------------------------------------------------
- Added view hooks after top section (thanks, Ben!)
- Fixed default access for objects created by dropbox (thanks, Steve!)

Fri, Aug 13, 2010
---------------------------------------------------------------------
- Stopped emails being associated with Campaigns that don't exist (thanks, Steve!)
- Fixed plugins tab initialization when the 'settings' table had not been created yet (thanks, Nathan!)

Thu, Aug 12, 2010
---------------------------------------------------------------------
- Fixed activerecord deprecation warnings (thanks, Nathan!)
- Fixed factory generator for email (thanks, Nathan!)

Tue, Aug 10, 2010
---------------------------------------------------------------------
- Added rules to .gitignore to ignore any plugins starting with crm_* (thanks, Nathan!)

Mon, Aug 9, 2010
---------------------------------------------------------------------
- Display absolute dates in addition to relative ones (thanks, Peter!)
- Add absolute dates and fix relative dates for campaigns (thanks, Peter!)

Sat, Aug 7, 2010
---------------------------------------------------------------------
- Make sure Task selection popup doesn't affect Quick Find.
- Close asset selection popup on <Enter>.
- Finished refactoring to move #attach logic from application controller to models.

Fri, Aug 6, 2010
---------------------------------------------------------------------
- Germal translation fixes (thanks, Ralf!)
- Removed Rails deprecation warnings (thanks, Ralf!)

Thu, Aug 5, 2010
---------------------------------------------------------------------
- Fat Free CRM by default requires Rails 2.3.8.
- Bundled will_paginate and faker as vendor/gems.

Wed, Aug 4, 2010
---------------------------------------------------------------------
- Made dropbox email address comparision was case-insensitve (thanks, Ralf!)
- Removed duplicate association Opportunity#account (was: has_one + belongs_to) (thanks, Ralf!)
- Multiple fixes for Rails 2.3.8 upgrade (thanks, Ralf!)

Tue, Aug 3, 2010
---------------------------------------------------------------------
- Don't auto-complete user create/edit forms (thanks, Alexander!)
- Multiple fixes in Germal translation (thanks, Ralf!)

Fri, Jul 30, 2010
---------------------------------------------------------------------
- If a contact has no name, fill in the account name instead (thanks, Peter!)

Wed, Jul 28, 2010
---------------------------------------------------------------------
- Sort contacts by last name by default (thanks, Peter!)

Tue, Jul 27, 2010
---------------------------------------------------------------------
- Fixed named scope condition syntax in the Opportunity model (thanks, Elad!)
- Refactored to move #attach logic from application controller to models.

Mon, Jul 12, 2010
---------------------------------------------------------------------
- Refactored to move #discard logic from application controller to models.

Thu, Jul 7, 2010
---------------------------------------------------------------------
- Added controller#attach specs.
- Added more comprehensive controller#discard specs.

Wed, Jul 7, 2010
---------------------------------------------------------------------
- Allow searching by email for Accounts, Contacts, and Leads.
- Added #discard controller specs.

Sun, Jul 4, 2010
---------------------------------------------------------------------
- Allow explicit controller name when refreshing sidebar.
- Handle #discard requests the same way #attach are handled (i.e. in parent object controller).

Fri, Jul 2, 2010
---------------------------------------------------------------------
- Moved common #attach handler to application controller.
- Strike through completed tasks in the auto_complete list.
- Implemented #discard for tasks.
- Implemented selecting and attaching tasks.
- Allow auto_complete for tasks.
- Implemented #attach for Opportunities and #attach/#discard for Contacts.
- Added #attach routes to handle requests to attach existing assets to related item.

Mon, Jun 12, 2010
---------------------------------------------------------------------
- Use default permissions when creating an account from within a contact (thanks, Matthiew!)
- Removed 'Custom' opportunity stage and replaced it with comment in config/settings.yml.
- Named scope fix for Postgres/Heroku (closes LH #213).

Wed, Jun 7, 2010
---------------------------------------------------------------------
- pt-BR updates (thanks, Enderson!)

Thu, Jun 17, 2010
---------------------------------------------------------------------
- Don't count lost opportunities towards Account total (closes LH #205).
- Fixed vertical offset of asset selection popup.
- Made multiple selection popups coexist on a single page.

Fri, Jun 11, 2010
---------------------------------------------------------------------
- Fixed issue with linking to edit/delete for models with multipart names (thanks, Nicholas!)

Tue, Jun 8, 2010
---------------------------------------------------------------------
- Added load_select_popups_for() helper on asset landing pages.
- Refactored to add sections with [Create/Select...] on landing pages.

Fri, Jun 4, 2010
---------------------------------------------------------------------
- Initial prototype of seleting related asset from the asset's landing page.
- Added discard action related specs.

Fri, May 28, 2010
---------------------------------------------------------------------
- Do not offer :converted status choice when creating new lead (closes LH #199).

Thu, May 27, 2010
---------------------------------------------------------------------
- Added simplified Chinese translation (thanks, James Zhang!)
- Initial implementation of discarding attached opportunity.

Tue, May 25, 2010
---------------------------------------------------------------------
- Final dropbox touches before merging it all to the master branch.
- Avoid collision with .email CSS class which is used to display Task category strip.
- Dropbox related localizations.

Mon, May 24, 2010
---------------------------------------------------------------------
- More work on the dropbox library.

Mon, May 10, 2010
---------------------------------------------------------------------
- Allow to detach an account when editing a contact or an opportunity (closes LH #184).

Wed, May 5, 2010
---------------------------------------------------------------------
- Added migration to have index on permissions (thanks, Yura!)
- Added link_to_email to Bcc: to dropbox if it has been set up (closes LH #183).

Mon, May 3, 2010
---------------------------------------------------------------------
- Pushed [rails3] branch to Github, let the porting start :-)

Thu, Apr 29, 2010
---------------------------------------------------------------------
- Replaced Facebox with Modalbox (closes LH #170).

Tue, Mar 9, 2010
---------------------------------------------------------------------
- Check if new [background_info] setting is properly loaded.
- Merged in dropdown calendar localization patches (thanks, Yura!)
- Updated list of contributors.
- Version 0.9.10

Fri, Feb 26, 2010
---------------------------------------------------------------------
- More work on to support scheduling tasks with specific time deadline.

Thu, Feb 25, 2010
---------------------------------------------------------------------
- Refactored compound address code to support field hints.
- Added French locale (thanks, Cédric!)

Wed, Feb 24, 2010
---------------------------------------------------------------------
- Added new hook hook in user profile template (thanks, Jose Luis!)

Sun, Feb 21, 2010
---------------------------------------------------------------------
- Added :background_info option to Settings making it optional
- Refactored background info in forms and sidebar views
- Fixed fixtures and factories for the new Address model

Fri, Feb 19, 2010
---------------------------------------------------------------------
- Added support for creating tasks with specific time deadline (thanks, Yura!)

Wed, Feb 17, 2010
---------------------------------------------------------------------
- Added support for compound addresses (thanks, Jose Luis!)
- Fixed for :quote_ident issue with Postgres (thanks, Matt!)
- Added missing translations to the rest of locale files.

Tue, Feb 16, 2010
---------------------------------------------------------------------
- Added localization support for dropdown calendar (thanks, Yura!)

Wed, Feb 10, 2010
---------------------------------------------------------------------
- Added background info field to all major models (thanks, Jose Luis!)
- Added hook to sidebar index template (thanks, Jose Luis!)

Tue, Feb 9, 2010
---------------------------------------------------------------------
- Default permissions are now configurable in settings.yml (thanks, Jose Luis!)
- More localization tweaks for date formats and tasks (thanks, Kamil and Yura!)
- Minor refactoring.

Sun, Feb 7, 2010
---------------------------------------------------------------------
- Updated Russian locale files (thanks, Roman!)
- Updated task editing to support localization (thanks, Yura!)
- Added email attribute to Accounts -- run rake db:migrate (thanks, Jose Luis!)
- Updated README to mention http://demo.fatfreecrm.com

Thu, Feb 4, 2010
---------------------------------------------------------------------
- Fixed few i18n omissions in locale files.
- Added support for editing and deleting notes (thanks, Jose Luis!)

Tue, Feb 2, 2010
---------------------------------------------------------------------
- Added Polish translation (thanks, Kamil!)

Wed, Jan 27, 2010
---------------------------------------------------------------------
- Fixed task time zone specs (thanks, Tom!)

Mon, Jan 25, 2010
---------------------------------------------------------------------
- Small tweak to better support Heroku deployments (thanks, Ryan!)

Tue, Jan 19, 2010
---------------------------------------------------------------------
- Updated Russian translation (thanks, Roman!)

Tue, Jan 12, 2010
---------------------------------------------------------------------
- Pulled remaining English strings out of JavaScript (thanks, Gavin!)
- Added missing message to locale files.

Mon, Jan 11, 2010
---------------------------------------------------------------------
- Added Spanish translation (thanks, Beatriz!)
- Fixed text encoding issues with Ruby 1.9/MySQL and HAML (thanks, Gavin!)

Wed, Jan 7, 2010
---------------------------------------------------------------------
- Added :per_user_locale setting (default is false).
- Added some CSS eye candy (drop shadows and options links).
- Version 0.9.9b

Wed, Jan 6, 2010
---------------------------------------------------------------------
- Updated Thai and Portuguese language translations.

Mon, Jan 4, 2010
---------------------------------------------------------------------
- Implemented REST API for fetching asset notes (thanks, Adrian!)

Sun, Jan 3, 2010
---------------------------------------------------------------------
- Return stringified hook data when called from within templates, and the actual data otherwise.

Thu, Dec 31, 2009
---------------------------------------------------------------------
- Version 0.9.9a -- Happy New Year!
- Added [rake crm:settings:show] task.
- Minor fixes.

Wed, Dec 30, 2009
---------------------------------------------------------------------
- More Ruby 1.9 compatibility fixes: all specs pass.

Tue, Dec 29, 2009
---------------------------------------------------------------------
- Fixed Ruby 1.9 compatibility issues with I18n.t (thanks, Gavin!)
- Fixed rendering of callback hooks to be compatible with Ruby 1.9.
- Fixed password reset submission form (thanks, Roman!)

Mon, Dec 28, 2009
---------------------------------------------------------------------
- XSS cleanup across views and models (thanks, Louis!)
- Refactoring permissions templates (thanks, Rit!)
- Updated README file.
- Version 0.9.9 (yay!)

Sat, Dec 19, 2009
---------------------------------------------------------------------
- Fixed deprecation warning when adding a new comment.
- Fixed Apache/Passenger issue of not being able to load tab settings.
- Merged in I18n branch: Fat Free CRM could be easily localized now by dropping in config/locales file.
- Added exception handling and custom 500 status code template.

Mon, Dec 14, 2009
---------------------------------------------------------------------
- Make sure no activity records are left behind when model record gets deleted from the database.

Sun, Dec 13, 2009
---------------------------------------------------------------------
- Fixed broken sidebar search in Admin/Users.
- Refactored sidebar rendering to explicitly check if template file exists.

Sat, Dec 12, 2009
---------------------------------------------------------------------
- Upgraded [simple_column_search] plugin that adds search support for Postgres.
- More I18n tweaks in views.
- Metallica show at HP Pavilion in San Jose!

Sun, Nov 29, 2009
---------------------------------------------------------------------
- Added optional PLUGIN=plugin parameter to "rake crm:settings:load" task.
- Sorted locale keys, synced up English, Portuguese, and Russian locale files.

Tue, Nov 24, 2009
---------------------------------------------------------------------
- Happy birthday, Fat Free CRM is one year old!

Wed, Nov 18, 2009
---------------------------------------------------------------------
- Added Thai language translation (thanks, Apirak!)

Mon, Nov 16, 2009
---------------------------------------------------------------------
- Streamlined CSS styles to fix text wrapping.
- Added explicit CSS value to fix tabs height (thanks, Apirak!)
- Fixed time calculations for dashboard activities.

Thu, Nov 12, 2009
---------------------------------------------------------------------
- Restructured settings to take advantage of locale.
- NOTE: re-run crm:settings:load

Wed, Nov 11, 2009
---------------------------------------------------------------------
- Moved hardcoded setting values from config/settings.yml to locale.

Mon, Nov 9, 2009
---------------------------------------------------------------------
- Merged with lanadv/i18n branch (thanks, Lana!)

Fri, Nov 6, 2009
---------------------------------------------------------------------
- Adjust total campaign revenue when related opportunity is won (LH #121).
- Refresh campaign sidebar when updating related opportunity (LH #121).
- Refresh campaign sidebar when rejecting or converting related lead (LH #121).
- Display newly created opportunity when converting lead from campaign page (LH #121).

Thu, Nov 5, 2009
---------------------------------------------------------------------
- Writing specs for LH #121.

Wed, Nov 4, 2009
---------------------------------------------------------------------
- Correctly set opportunity campaign and source when converting a lead (LH #119).
- Show correct campaign name and source when adding a lead from campaign landing page.
- Update lead counters when reassigning leads between campaigns (LH #117).

Sun, Nov 1, 2009
---------------------------------------------------------------------
- Implemented I18n for options across all models.

Sat, Oct 31, 2009
---------------------------------------------------------------------
- Correctly show opportunity summary when opportunity stage hasn't been specified.
- Update Campaign summary when creating or deleting related lead or opportunity.
- Fixed "rake crm:setup" task to be compatible with ruby 1.9.

Fri, Oct 30, 2009
---------------------------------------------------------------------
- Introduced Sortable module, more work on I18n.

Sat, Oct 24, 2009
---------------------------------------------------------------------
- Allow renaming both main and admin tabs (see config/settings.yml).
- Refactored gravatars to always show default image if gravatar is missing.
- Fixed Facebox usage within Admin area.
- Release 0.9.8a.

Thu, Oct 22, 2009
---------------------------------------------------------------------
- Fixed SASS deprecation warnings making it compatible with Heroku again (thanks, Jim!).
- Refactored Facebox library (again!) to take into account [base_url] setting.

Wed, Oct 21, 2009
---------------------------------------------------------------------
- Include modules from "lib/fat_free_crm.rb" so that they're loaded when running rake.

Tue, Oct 20, 2009
---------------------------------------------------------------------
- Added Language option stubs to user's profile.
- Disabled tab highlighting when showing user's profile.
- Include all Fat Free CRM modules from Rails initializer.
- Added FatFreeCRM::I18n module.

Sun, Oct 18, 2009
---------------------------------------------------------------------
- Merged localization commits onto i18n branch (thanks, Lana!)

Wed, Oct 14, 2009
---------------------------------------------------------------------
- Make sure opportunity name does not exceed 64 characters (thanks, Rit!)
- Changed required Rails version to v2.3.4
- Updated model annotations for schema version #023.
- Release 0.9.8.

Sun, Oct 11, 2009
---------------------------------------------------------------------
- Added full support for deploying Fat Free CRM in subdirectory (see config/settings.yml).
- Made Facebox library work with the project is deployed in subdirectory.

Sat, Oct 10, 2009
---------------------------------------------------------------------
- Happy birthday, Diana!
- Setting up Apache with the latest Passenger.

Fri, Oct 9, 2009
---------------------------------------------------------------------
- Prevent multiple form submissions by pressing [Submit] button twice.
- Fixed apparent MySQL migration error on Windows/XP.

Wed, Oct 7, 2009
---------------------------------------------------------------------
- Moved [uses_user_permission] code from plugin to core library.
- Added inspector logging.

Mon, Oct 5, 2009
---------------------------------------------------------------------
- Added [rake crm:hooks] task that enumerates the hooks (thanks, Eric!)

Sat, Oct 3, 2009
---------------------------------------------------------------------
- Removed [uses_mysql_uuid] plugin and deprecated support for UUIDs.

Tue, Sep 29, 2009
---------------------------------------------------------------------
- Adjusted activity timestamp to reflect UTC offset (thanks, Andrew!)
- Allow creating opportunities with non-unique name.
- Added :auto_complete controller hook.

Sun, Sep 27, 2009
---------------------------------------------------------------------
- Added sidebar hooks on asset landing pages.
- crm_tags: added support for showing tags on asset landing pages.

Sat, Sep 26, 2009
---------------------------------------------------------------------
- Added hooks for inline CSS styles and JavaScript epilogue.
- crm_tags: added JavaScript and CSS stylesheets for tags.
- crm_tags: make sure tags stay unique when searching.

Thu, Sep 24, 2009
---------------------------------------------------------------------
- crm_tags: Made controller methods work with query string that contains tags.

Tue, Sep 22, 2009
---------------------------------------------------------------------
- crm_tags: Proof of concept of combining query string with hash-prefixed tags.

Mon, Sep 21, 2009
---------------------------------------------------------------------
- Added hooks to model view partials.

Mon, Sep 21, 2009
---------------------------------------------------------------------
- Added hooks to model view partials.

Sun, Sep 20, 2009
---------------------------------------------------------------------
- More work on [crm_tags] plugin.

Fri, Sep 18, 2009
---------------------------------------------------------------------
- Merged String#to_url (thanks, Rit!)

Thu, Sep 17, 2009
---------------------------------------------------------------------
- Fixed task completion bug for tasks with specific due date (thanks, Andrew!)
- Added more task model specs.

Mon, Sep 14, 2009
---------------------------------------------------------------------
- Merged in Andrew's patch that solves disappearing tasks puzzle (thanks, Andrew!)
- Created task model specs that prove Andrew's theory.

Sun, Sep 13, 2009
---------------------------------------------------------------------
- Added [get_*] controller hooks.
- Refactored FatFreeCRM::Callback.hook to simplify and support hook chains.
- Implemented controller hooks in [crm_tags] plugin.

Sat, Sep 12, 2009
---------------------------------------------------------------------
- Added [*_top_section_bottom] view hooks.
- Make Rails not to reload core classes when developing a plugin.

Thu, Sep 10, 2009
---------------------------------------------------------------------
- More work on [crm_tags] plugin and its view hooks.

Wed, Sep 9, 2009
---------------------------------------------------------------------
- Injecting [acts_as_taggable_on] to existing models.

Mon, Sep 7, 2009
---------------------------------------------------------------------
- Started with [crm_tags] plugin.

Sun, Sep 6, 2009
---------------------------------------------------------------------
- Release 0.9.7.
- Open up [Quick find] on click rather than on mouseover.
- Added bounce effect to the login screen (fun!).
- Added CONTRIBUTORS file.

Sat, Sep 5, 2009
---------------------------------------------------------------------
- Added overlay to the facebox library.
- Upgraded Rails Engines plugin (edge 2009-06-16).
- Boot Rails Engines right after Rails boots itself up.

Thu, Sep 3, 2009
---------------------------------------------------------------------
- Make sure [rake crm:setup:admin] can actually assign admin attribute (thanks Rit!)
- Correctly assign and revoke admin rights in Admin/Users (thanks Rit!)
- Refactored Tabs code to avoid duplication.

Tue, Sep 1, 2009
---------------------------------------------------------------------
- Fixed user signup vulnerability (thanks, Rit!)
- Suppress terminal echo when asking for admin password in [rake crm:setup:admin] task.

Sun, Aug 30, 2009
---------------------------------------------------------------------
- Get flip_subtitle working in IE8 (thanks, Hamish!)
- Make sure simple_column_search does not escape period and single quote (thanks, Rit!)
- Don't suspend Admin users (thanks, Rit!)
- Moved [crm_sample_tabs] plugin into separate repository.
- Merged plugin tab support into the master branch.

Sat, Aug 29, 2009
---------------------------------------------------------------------
- Some refactoring and more comments explaining the examples in [crm_sample_plugin].

Thu, Aug 27, 2009
---------------------------------------------------------------------
- Make sure we can run Rake tasks when Settings are missing.
- Reload User class in [rake crm:setup] task to make sure migration attributes are set.
- Make sure the user has been authenticated before checking whether she is awaiting approval.

Wed, Aug 26, 2009
---------------------------------------------------------------------
- Implemented #tab method for plugin registration.

Tue, Aug 25, 2009
---------------------------------------------------------------------
- Added [crm_sample_tabs] plugin with the tab registration prototype.

Mon, Aug 24, 2009
---------------------------------------------------------------------
- Implemented user approvals in Admin/Users and closed LH #29.
- Release 0.9.6.

Sat, Aug 22, 2009
---------------------------------------------------------------------
- Implemented :needs_approval setting for user signups.

Fri, Aug 21, 2009
---------------------------------------------------------------------
- Added new :user_signup setting (see config/settings.yml).
- User signups are only allowed if :user_signup is set to :allowed or :needs_approval.

Thu, Aug 20, 2009
---------------------------------------------------------------------
- Added support for unattended [rake crm:setup] and [rake crm:setup:admin] tasks.
- Warn about database reset in [rake crm:setup] task.
- Removed dependency on Highline gem and removed it from vendors/gems.
- Added [:user_signup] setting and started with the signup permissions.

Wed, Aug 19, 2009
---------------------------------------------------------------------
- Added view hooks on landing pages of all major models.

Tue, Aug 18, 2009
---------------------------------------------------------------------
- More work on [crm_issues] plugin.

Mon, Aug 17, 2009
---------------------------------------------------------------------
- Work on [crm_issues] plugin.

Sat, Aug 15, 2009
---------------------------------------------------------------------
- Implemented plugin dependencies to be able to change plugin loading order.
- Pass on [lead.id] when converting it into a contact (LH #86).
- Corrected format of opportunity closing date (GH #7).

Fri, Aug 14, 2009
---------------------------------------------------------------------
- Reviewed pccl fork and [fat_free_issues] plugin.

Thu, Aug 13, 2009
---------------------------------------------------------------------
- Added user search and pagination to Admin/Users.

Wed, Aug 12, 2009
---------------------------------------------------------------------
- Adding search and pagination to Admin/Users.

Tue, Aug 11, 2009
---------------------------------------------------------------------
- Installed [Highline] gem in vendor/gems for [rake crm:setup:admin] task.
- Implemented [rake crm:setup:admin] task to create admin user.

Sat, Aug 8, 2009
---------------------------------------------------------------------
- Added :before_destroy filters for User model.
- Implemented deleting users in Admin interface.
- Refactored flash messages to set notice/warning class on the fly.

Wed, Aug 5, 2009
---------------------------------------------------------------------
- Added confirmation when deleting an user (Admin/Users/Delete).

Tue, Aug 4, 2009
---------------------------------------------------------------------
- Upgraded [acts_as_commentable] plugin for Ruby 1.9 compatibility.
- Updated tab settings to allow Fat Free CRM to run from a subdirectory (thanks, okyada!).
- Updated [rake crm:settings:load] task to ensure Rails 2.3.3 compatibility.
- Implemented Admin > [Edit User] form.

Mon, Aug 3, 2009
---------------------------------------------------------------------
- Implemented Admin > [Create User] form.
- Include all application helpers except the ones in /admin/helpers subdirectory (GH #5).
- Make sure editing assets doesn't change asset owner (LH #79).
- Implemented [Suspend] and [Reactivate] when managing users.
- Prevent suspended user from logging in.

Sun, Aug 2, 2009
---------------------------------------------------------------------
- Updated authentication to allow creating users with blank passwords.

Sat, Aug 1, 2009
---------------------------------------------------------------------
- More work on Admin/Users: added list of users and [Create User] form.

Fri, Jul 31, 2009
---------------------------------------------------------------------
- Added [suspended_at] to User model, fixed typo (LH #81).

Thu, Jul 30, 2009
---------------------------------------------------------------------
- Fixed ActionMailer password reset issue (thanks, James!).
- Use truncate() instead of shorten() for multibyte chars (thanks, Dima!).
- Increased the size of the textarea when adding notes (LH #80).

Wed, Jul 29, 2009
---------------------------------------------------------------------
- More work on building the Admin infrastructure.

Tue, Jul 28, 2009
---------------------------------------------------------------------
- Building Admin infrastructure.

Mon, Jul 27, 2009
---------------------------------------------------------------------
- Dropped open_id related tables, added [admin] flag to [users] table.

Sun, Jul 26, 2009
---------------------------------------------------------------------
- Added timezone support.

Fri, Jul 24, 2009
---------------------------------------------------------------------
- Fixed a typo that affected individual permissions (thanks, Guillermo!)
- Refactored password reset controller and related views.
- Merged in Spanish translation from chillicoder/master (thanks, Martin!).
- Release 0.9.5.

Thu, Jul 23, 2009
---------------------------------------------------------------------
- Made UUID support optional (affects MySQL v5+ users only).
- Removed task-specific flash area; changed to use generic flash messages instead.
- Store current user in the class to make it easier to access it from observers.
- Removed password length restriction to allow blank passwords.

Tue, Jul 21, 2009
---------------------------------------------------------------------
- Upgraded HAML/SASS to version 2.2.2 (Powerful Penny) and made it a plugin.
- Ruby 1.9.1 compatibility fixes.

Mon, Jul 20, 2009
---------------------------------------------------------------------
- Happy birthday, Lana!
- Annotated models for schema version #19.
- Implemented Profile > Change Password.
- Added ability to show flash notices from RJS templates.
- Removed [open_id_authentication] plugin since it's no longer needed.
- First gathering at #fatfreecrm channel on irc.freenode.net (thanks, Eric!)

Sun, Jul 19, 2009
---------------------------------------------------------------------
- Completed upgrade to Authlogic 2.1.2
- Removed support for OpenID authentication

Sat, Jul 18, 2009
---------------------------------------------------------------------
- Upgrading to Authlogic 2.1.2

Wed, Jul 15, 2009
---------------------------------------------------------------------
- Moved avatars in separate directories based on who the avatar belongs to.
- Implemented avatar_for() to encapsulate uploaded image, gravatar, and default icon.
- Fixed Paperclip bug when :url option is a lambda and not a string.
- Release 0.9.4.

Mon, Jul 13, 2009
---------------------------------------------------------------------
- Finished with user avatar upload, including controller and view specs.

Sun, Jul 12, 2009
---------------------------------------------------------------------
- Back home from Pismo Beach.

Thu, Jul 9, 2009
---------------------------------------------------------------------
- On my way to Pismo Beach, CA.

Tue, Jul 7, 2009
---------------------------------------------------------------------
- More tweaks for Profile > Upload Avatar form.

Mon, Jul 6, 2009
---------------------------------------------------------------------
- Replaced [mini_magick/has_image] combo with [paperclip] plugin.
- Installed [responds-to-parent-plugin].
- Added [Avatar] model.
- Implemented Ajax avatar uploads through hidden frame.

Sun, Jul 5, 2009
---------------------------------------------------------------------
- Installed [mini_magick] gem and [has_image] plugin.

Sat, Jul 4, 2009
---------------------------------------------------------------------
- Finished [Edit Profile] form which now updates all other page elements.
- Use root route instead of home (thanks, Dr.Nic!)

Fri, Jul 3, 2009
---------------------------------------------------------------------
- Added user controller and view specs.
- Converted [Edit Profile] form to Ajax, implemented update.

Wed, Jul 1, 2009
---------------------------------------------------------------------
- Added copyright notices (thanks, Michael!).
- Added routes and Ajax form stubs for [Edit Profile], [Upload Avatar], and [Change Password].

Tue, Jun 30, 2009
---------------------------------------------------------------------
- More work on user profile.
- Applied patches to fix an issue with comments and their formatting (thanks, Eric!).

Sun, Jun 28, 2009
---------------------------------------------------------------------
- Another iteration on User Profiles; all users now have personal profile page.
- Fixed form validation issue on asset landing pages (closes GH #3).
- Refactored form validation specs.
- Release 0.9.3.

Sat, Jun 27, 2009
---------------------------------------------------------------------
Combined [Preferences] and [Profile] into single [Preferences] menu item.

Thu, Jun 25, 2008
---------------------------------------------------------------------
- Hide [Create...] form before showing [Edit...] to make sure initial focus gets set properly.
- Rewrote config/settings.yml to use more familiar Ruby-like syntax.

Mon, Jun 22, 2009
---------------------------------------------------------------------
- Fat Free CRM website is up at http://www.fatfreecrm.com

Sat, Jun 20, 2009
---------------------------------------------------------------------
- Assets now show all related tasks, even if they were not created or assigned by current user.
- Release 0.9.2.

Fri, Jun 19, 2009
---------------------------------------------------------------------
- Revamping the way a list of tasks is shown on related asset page.
- Added [completed_by] field to Task model to be able to show who completed the task.

Thu, Jun 18, 2009
---------------------------------------------------------------------
- Fixed task creation issue on landing pages; added missing task stylesheets.
- Simplified version handling to avoid unnecessary database queries.
- Fixed Rails 2.3 incompatibility (expand/collapse in forms and [Cancel] for notes).
- Changed defaults to more reasonable values (thanks, Lana!).

Mon, Jun 15, 2009
---------------------------------------------------------------------
- Updated Readme file (added links to direct downloads and Google Groups).
- Installed [facebox-for-prototype] JavaScript library.
- Implemented About box showing version number and helpful links (rerun rake crm:setup!)

Sat, Jun 13, 2009
---------------------------------------------------------------------
- Upgraded to work with Rails 2.3.2
- Upgraded [rspec], [rspec-rails], and [open-id-authentication] plugins.
- Upgraded [acts-as-paranoid] plugin.
- Fixed task title naming issue.
- Fixed opportunity unique index issue (SQLite).
- Tagged 0.9.0 to build downloadable distributions on Github.

Thu, Jun 11, 2009
---------------------------------------------------------------------
- Finished user options for the Recent Activity (LH #46).
- Fixed sporadic spec failures when running with SQLite.

Wed, Jun 10, 2009
---------------------------------------------------------------------
- Implemented options for Opportunities and Contacts.
- Started with the options for the Recent Activity.

Tue, Jun 9, 2009
---------------------------------------------------------------------
- Implemented options for Accounts.

Sun, Jun 6, 2009
---------------------------------------------------------------------
- Implemented options for Leads.
- Happy birthday, Rema!

Thu, Jun 4, 2009
---------------------------------------------------------------------
- Implemented :sort_by option for Campaigns.
- Wrote specs and finished [Options] for Campaigns.

Wed, Jun 3, 2009
---------------------------------------------------------------------
- Implemented :per_page, and :format user preferences for Campaigns.
- Revisited user Preference model and wrote full spec coverage.
- Refactored application.js to simplify remote form updates.
- Updated stylesheets to support long and brief list formats.

Tue, Jun 2, 2009
---------------------------------------------------------------------
- Added [Options] form for Campaigns with all preferences stubbed.

Mon, Jun 1, 2009
---------------------------------------------------------------------
- Happy birthday, Sophie!

Sun, May 31, 2009
---------------------------------------------------------------------
- Work on adding [Options] inline form and related controller actions.

Sat, May 30, 2009
---------------------------------------------------------------------
- Implemented crm.Menu class and added menu related CSS styles.

Fri, May 29, 2009
---------------------------------------------------------------------
- Fixed opportunity assignment issue reported by Deepu (LH #49).
- Fixed similar issue with the contact assignments.
- Fixed account sidebar issue when shipping/billing addresses are missing.

Thu, May 28, 2009
---------------------------------------------------------------------
- Server installation and configuration at Linode.

Wed, May 27, 2009
---------------------------------------------------------------------
- Refactored auto_complete to use before_filter.
- Created shared behavior specs to test auto_complete.
- Display a message when no quick find matches were found.
- Uninstalled [auto_complete] plugin since we're not using it.
- Signed up for Linode.com

Tue, May 26, 2009
---------------------------------------------------------------------
- Happy birthday, Laura!

Mon, May 25, 2009
---------------------------------------------------------------------
- Implemented jumpbox (called "Quick Find").

Sun, May 24, 2009
---------------------------------------------------------------------
- More work on jumpbox.

Sat, May 23, 2009
---------------------------------------------------------------------
- Restructured application's JavaScript and added crm.Popup class.
- Added "Jump to..." link that shows the jumpbox (see LH #45).

Fri, May 22, 2009
---------------------------------------------------------------------
- Happy birthday, Dad!

Thu, May 21, 2009
---------------------------------------------------------------------
- Fixed JavaScript and CSS caching issues in production environment.

Wed, May 20, 2009
---------------------------------------------------------------------
- Gracefully handle use cases when previous or related asset is deleted or protected.
- Make sure commentable object exists and is accessible to current user.
- Implemented specs for Comments controller.

Tue, May 19, 2009
---------------------------------------------------------------------
- Added missing and protected object handling for #convert, #promote, #reject (Leads).
- Added new [tracked_by] named scope for Tasks.
- Added missing and protected object handling for Tasks.
- Refactored rescue clause to use respond_to_not_found().

Mon, May 18, 2009
---------------------------------------------------------------------
- Added missing and protected object handling for #update and #delete (all except Tasks).

Sun, May 17, 2009
---------------------------------------------------------------------
- Added missing object handling for #edit action (all core objects except Tasks).
- If object permissions prevent access, treat the object as missing.
- Refacoring: use more idiomatic Rails named scope (User#except).

Sat, May 16, 2009
---------------------------------------------------------------------
- Added missing object handling for #show action (all core objects except Tasks).
- Added controller routing specs for new routes.

Fri, May 15, 2009
---------------------------------------------------------------------
- Replaced explicit MySQL trigger creation with [add_uuid_trigger].

Thu, May 14, 2009
---------------------------------------------------------------------
- Started with LH #34 (Gracefully handle missing objects).
- Replaced regular flash messages with non-sticky ones.
- Make sure search box gets shown after creating, updating, or deleting an account.

Wed, May 13, 2009
---------------------------------------------------------------------
- Implemented search for campaigns, opportunities, accounts, and contacts.
- Made it easier to reject leads (LH #35).
- Added sidebar summary for accounts.
- Added web presence links for leads and contacts.

Tue, May 12, 2009
---------------------------------------------------------------------
- Added company field to leads search.

Mon, May 11, 2009
---------------------------------------------------------------------
- Implemented live search for leads that can be reused in other controllers.
- Fixed demo data generation to produce random recently viewed items list.

Sun, May 10, 2009
---------------------------------------------------------------------
- More work on simplifying search.

Fri, May 8, 2009
---------------------------------------------------------------------
- Created initial implementation of live search (Leads only so far).

Thu, May 7, 2009
---------------------------------------------------------------------
- Installed [simple_column_search] plugin.
- Initial implementation of live search for Leads.

Wed, May 6, 2009
---------------------------------------------------------------------
- Implemented prototype search box for Leads with stubbed controller.

Tue, May 5, 2009
---------------------------------------------------------------------
- Started with live search (LH #22).

Mon, May 4, 2009
---------------------------------------------------------------------
- Last bit of paging refactoring before closing LH #18.

Sun, May 3, 2009
---------------------------------------------------------------------
- Implemented Ajax pagination for Opportunities.
- Simplified paging by using single proxy to store and retrieve current page.

Sat, May 2, 2009
---------------------------------------------------------------------
- Implemented Ajax pagination for Contacts.

Fri, May 1, 2009
---------------------------------------------------------------------
- Implemented Ajax pagination for Campaigns.

Thu, Apr 30, 2009
---------------------------------------------------------------------
- Implemented Ajax pagination for Accounts.

Wed, Apr 29, 2009
---------------------------------------------------------------------
- Implemented Ajax pagination for Leads.

Tue, Apr 28, 2009
---------------------------------------------------------------------
- Started to explore alternative approach to pagination (see Leads).

Mon, Apr 27, 2009
---------------------------------------------------------------------
- Initial implementation of on demand paging (Accounts only so far).
- Fixed SQLite incompatibilities (thanks, James!)
- Restructured pagination templates and added specs.

Sun, Apr 26, 2009
---------------------------------------------------------------------
- Researched on demand paginations, and [will_paginate].

Sat, Apr 25, 2009
---------------------------------------------------------------------
- Installed [will_paginate] plugin.

Fri, Apr 24, 2009
---------------------------------------------------------------------
- Happy birthday -- we're 5 month old ;-)
- Make sure tasks don't get onto recently viewed items list.
- Added "completed", "reassigned", and "rescheduled" activity logs for tasks (closes LH #17).

Thu, Apr 23, 2009
---------------------------------------------------------------------
- Filter activities based on asset permissions, even for deleted assets.
- Pulled in first patches from fork (thanks, Scott!)

Wed, Apr 22, 2009
---------------------------------------------------------------------
- Filter activities based on asset permissions (existing assets only so far).

Tue, Apr 21, 2009
---------------------------------------------------------------------
- Honor object permissions when displaying activity log (LH #17).

Mon, Apr 20, 2009
---------------------------------------------------------------------
- Finished with recently viewed items sidebar panel (LH #28).

Sun, Apr 19, 2009
---------------------------------------------------------------------
- Refresh recently viewed items when creating, editing, or deleting core objects.

Sat, Apr 18, 2009
---------------------------------------------------------------------
- Scraped the idea of demo factories -- fixtures are easier to use and maintain.
- Updated demo fixtures and crm:demo:load task to simulate user activities and recently viewed items.
- Implemented "commented on" user activity type.

Fri, Apr 17, 2009
---------------------------------------------------------------------
- Back from LA and UCSB.

Thu, Apr 16, 2009
---------------------------------------------------------------------
- More work on demo factories: loading users and accounts.

Wed, Apr 15, 2009
---------------------------------------------------------------------
- Creating, updating, or deleting core assets also updates recently viewed items list.

Tue, Apr 14, 2009
---------------------------------------------------------------------
- Fixed missing uuid generation caused by observing models.

Mon, Apr 13, 2009
---------------------------------------------------------------------
- Harv Ecker is up in San Francisco tonight.

Sun, Apr 12, 2009
---------------------------------------------------------------------
- Initial implementation of recently visited items.

Sat, Apr 11, 2009
---------------------------------------------------------------------
- Lovely IRS weekend.

Fri, Apr 10, 2009
---------------------------------------------------------------------
- Added activity tracking for recently viewed items.
- Added activity named scopes to select records by user and action.

Thu, Apr 9, 2009
---------------------------------------------------------------------
- Fixed activity time-stamp format in Dashboard.

Wed, Apr 8, 2009
---------------------------------------------------------------------
- Created Activity model, related table, and factory.
- Basic initial implementation of activity observers and recent activity.
- Created specs for activity observers.

Tue, Apr 7, 2009
---------------------------------------------------------------------
- Added quick reschedule links to [Edit Task].
- Finished with editing tasks.

Mon, Apr 6, 2009
---------------------------------------------------------------------
- Introduced called_from_(index|landing)_page? helpers.
- A couple of bug fixes (hiding [Lead Convert] and handling HTTP :delete).

Sun, Apr 5, 2009
---------------------------------------------------------------------
- More tweaks rescheduling and reassigning tasks.

Sat, Apr 4, 2009
---------------------------------------------------------------------
- Added :before_update hooks for task along with related model specs.
- Renamed [task.due_at_hint] to [task.bucket] to simplify naming conventions.
- Initial implementation of task rescheduling and reassigning.

Fri, Apr 3, 2009
---------------------------------------------------------------------
- Moved [Edit Task] cancellation logic from controller to view.

Thu, Apr 2, 2009
---------------------------------------------------------------------
- Added view specs for task#destroy, fixed a couple task related bugs.
- Refactored view specs.

Wed, Apr 1, 2009
---------------------------------------------------------------------
- Finished [Edit Lead] views and view specs.
- Started with [Edit Task] form and related views.
- Refactored create, edit, and complete task views and created the specs.

Tue, Mar 31, 2009
---------------------------------------------------------------------
- More work on [Edit Lead] views and specs.

Mon, Mar 30, 2009
---------------------------------------------------------------------
- More work on [Edit Lead] form (leads controller and its specs).

Sun, Mar 29, 2009
---------------------------------------------------------------------
- Finished with [Edit Campaign] including controller and view specs.

Sat, Mar 28, 2009
---------------------------------------------------------------------
- Fixed updating permissions bug in [uses_user_permissions] plugin.
- Fixed editing shared permissions for opportunities, contacts, and accounts.

Thu, Mar 26, 2009
---------------------------------------------------------------------
- Refactored custom Rails initializers and added custom date format.
- Finished with [Edit Opportunity] including full controller and views specs.
- Fixed JavaScript bug caused by not wiping out hidden create form.
- Use String#shorten instead of truncate() helper.

Wed, Mar 25, 2009
---------------------------------------------------------------------
- More work on [Edit Opportunity] and its specs.

Tue, Mar 24, 2009
---------------------------------------------------------------------
- Finished with [Edit Contacts] including full controller and views specs.

Mon, Mar 23, 2009
---------------------------------------------------------------------
- Finishing touches for [Edit Contacts] forms.
- Moved sidebar to the lefthand column, changes location of Sass templates.
- Added [x] close button to all inline forms.

Sat, Mar 21, 2009
---------------------------------------------------------------------
- More work on [Edit Contact] form (spec coverage pending).
- Fixed task controller specs when due tomorrow == due this week.
- Added spec coverage for [Edit Contact].
- Added [x] form control, link_to_cancel and link_to_close helpers.

Fri, Mar 20, 2009
---------------------------------------------------------------------
- More work on editing a contact.

Wed, Mar 18, 2009
---------------------------------------------------------------------
- Updated view specs to use Factories, 100% pass.
- Updated task controller specs to use Factories.
- A week of transition to [factory_girl] is over: 317 specs, all green.

Mon, Mar 16, 2009
---------------------------------------------------------------------
- Refactored leads controller specs using factories.

Sun, Mar 15, 2009
---------------------------------------------------------------------
- Started refactoring leads controller specs.

Sat, Mar 14, 2009
---------------------------------------------------------------------
- Implemented specs for Account views and Home controller.
- Implemented specs for Campaigns controller.

Fri, Mar 13, 2009
---------------------------------------------------------------------
- Implemented specs for Settings model.

Thu, Mar 12, 2009
---------------------------------------------------------------------
- 100% spec code coverage for Accounts, Contacts, and Opportunities.

Wed, Mar 11, 2009
---------------------------------------------------------------------
- Installed [factory_girl] plugin.
- Created model factories for all core models.
- Rewrote account controller specs to use factories instead of mocks.
- Started refactoring opportunity controller specs to use factories instead of mocks
- Added #as_hash and #invert class methods to Settings

Tue, Mar 10, 2009
---------------------------------------------------------------------
- Put in place inline for Lead editing and conversion.
- Started with inline forms for Task editing.
- Depreciated contexts, refactored application's JavaScript.

Mon, Mar 9, 2009
---------------------------------------------------------------------
- Put in place inline edit forms for Campaigns, Accounts, Contacts, and Opportunities.

Sun, Mar 8, 2009
---------------------------------------------------------------------
- More work on inline edit and create forms.

Sat, Mar 7, 2009
---------------------------------------------------------------------
- Moved context code to module and made it available to controllers and views.
- Started with [Edit Contact] form.

Fri, Mar 6, 2009
---------------------------------------------------------------------
- Implemented [Edit Account] form.
- Implemented basic functions of [Edit Campaign].

Thu, Mar 5, 2009
---------------------------------------------------------------------
- Moved some JavaScript code from helpers to application.js.
- Added support for showing interchangeable inline forms (Convert and Edit).
- Refactored saving/restoring context for inline forms.

Wed, Mar 4, 2009
---------------------------------------------------------------------
- Refactored tools menu in lists to use block div.
- Refactored lead conversion to use remote form.
- Started with the [Edit Lead] inline form.

Tue, Mar 3, 2009
---------------------------------------------------------------------
- Refactored lead star rating to always show 5 stars (grayed out or not).
- Removed [notes] field from core models and forms.
- Created v0.1 "Steinitz" milestone and tickets for "Steinitz" release.
- Set up GitHub service hook to integrate commits with the Lighthouse.

Mon, Mar 2, 2009
---------------------------------------------------------------------
- Implemented Lead and Contact summary sidebar for individual Leads and Contacts.

Sun, Mar 1, 2009
---------------------------------------------------------------------
- Added core extension library.
- Implemented Opportunity summary sidebar for individual Opportunity.

Sat, Feb 28, 2009
---------------------------------------------------------------------
- Added gravatar support for leads and contacts.

Fri, Feb 27, 2009
---------------------------------------------------------------------
- Added [gravatar] plugin and implemented gravatars for notes.

Thu, Feb 26, 2009
---------------------------------------------------------------------
- Github commits are up on Twitter at http://twitter.com/fatfreecrm
- More refactoring to simplify handling of inline forms.
- Implemented adding related tasks for Leads, Accounts, Contacts, and Opportunities.

Wed, Feb 25, 2009
---------------------------------------------------------------------
- Refactored tasks, added ability to create related tasks (Campaigns only so far).

Tue, Feb 24, 2009
---------------------------------------------------------------------
- Implemented adding opportunities from the [Campaign] landing page.
- Implemented adding opportunities from [Contact] landing page.
- Implemented adding contacts from [Opportunity] landing page.
- Three months anniversary ;-).

Mon, Feb 23, 2009
---------------------------------------------------------------------
- Implemented adding leads from the [Campaign] landing page.
- Implemented adding contacts from the [Account] landing page.
- Implemented adding opportunities from the [Account] landing page.
- Updated README file.

Sun, Feb 22, 2009
---------------------------------------------------------------------
- Adding parent object support for inline forms.

Fri, Feb 20, 2009
---------------------------------------------------------------------
- Major refactoring to support inline form embedding throughout the system.

Thu, Feb 19, 2009
---------------------------------------------------------------------
- Simplified storing expand/collapse state for form sections.
- Started refactoring to support inline form embedding.

Wed, Feb 18, 2009
---------------------------------------------------------------------
- Converted [Create...] forms to remote to be able to reuse them inline.
- Refactored javascript and stylesheet includes for popup calendar control.
- Consolidated scattered inline stylesheets into single shared partial.

Tue, Feb 17, 2009
---------------------------------------------------------------------
- Refactored styles, added [Campaign] to [Lead] and [Opportunity] landing pages.
- Added [Contacts] and [Opportunities] to [Account] landing page.
- Added [Accounts] and [Opportunities] to [Contact] landing page.
- Added [Accounts] and [Campaigns] to [Opportunity] landing page.
- Refactored JavaScript code to automatically set focus on first form field.

Mon, Feb 16, 2009
---------------------------------------------------------------------
- Save shown/hidden state of [post a note] form for all commentable models.
- Updated controller and view specs to support commentables.
- Added comments fixture to generate sample comments for all the core models.

Sun, Feb 15, 2009
---------------------------------------------------------------------
- Implemented adding notes for campaign.
- Added notes for other core models (Account, Contact, Lead, and Opportunity).

Sat, Feb 14, 2009
---------------------------------------------------------------------
- More design work on campaign landing page (adding comments, etc.)

Fri, Feb 13, 2009
---------------------------------------------------------------------
- Implemented Campaign Summary sidebar for the campaign landing page.
- Generated [Comment] scaffold and created database migration.
- Added [acts_as_commentable] to core models.
- Added visible/invisible helpers to flip element's visibility style.

Thu, Feb 12, 2009
---------------------------------------------------------------------
- Installed [acts_as_commentable] plugin.
- More work designing simple and consistent landing pages.

Wed, Feb 11, 2009
---------------------------------------------------------------------
- Researching and mocking up landing pages for campaigns and leads.

Tue, Feb 10, 2009
---------------------------------------------------------------------
- Implemented creating and assigning tasks for the specific date from the calendar.

Mon, Feb 9, 2009
---------------------------------------------------------------------
- Converted remaining forms to HAML and the stylesheet to SASS.

Sun, Feb 8, 2009
---------------------------------------------------------------------
- Added custom logger to highlight logged messages.
- Added [task_at_hint] field to [tasks] table to capture due date request.
- Refactored task model and crm.date_select_popup() in application.js.

Sat, Feb 7, 2009
---------------------------------------------------------------------
- Created initial implementation of adding a new task (all except specific date).
- Refactored tasks code to simplify filtering.
- Implemented flipping between dropdown and calendar popup.
- Updated task related controller and view specs.

Fri, Feb 6, 2009
---------------------------------------------------------------------
- Finished implementing after_filter callback hook in [web-to-lead] plugin.
- Implemented tasks deletion for all three views.
- More fun with SASS stylesheets -- pretty cool stuff.

Thu, Feb 5, 2009
---------------------------------------------------------------------
- More work researching application's after_filter and making it work right.

Wed, Feb 4, 2009
---------------------------------------------------------------------
- Added [app_after_filter] hook and moved the rest of [web-to-lead] code to plugin.
- Started converting CSS to SASS.

Tue, Feb 3, 2009
---------------------------------------------------------------------
- Added README.rdoc and sample database configuration files, updated sample users.
- Added :app_before_filter hook, extracted [web-to-lead] code and moved it to plugin.
- Tweaks to login and signup forms (to be converted to HAML soon).

Mon, Feb 2, 2009
---------------------------------------------------------------------
- Updated task related controller and view specs.
- Extracted sample plugin and moved it into separate Git repository.

Sun, Feb 1, 2009
---------------------------------------------------------------------
- SuperBowl!!
- Refactored tasks controller to offload most of sidebar and filter processing to task model.
- Impletented tasks/complete for pending tasks.

Sat, Jan 31, 2009
---------------------------------------------------------------------
- [Create new task] and [Assign new task] forms now save/restore their display state.
- Implemented task filtering for all three views.
- Added completion checkboxes and created initial implementation.

Fri, Jan 30, 2009
---------------------------------------------------------------------
- Ruby 1.9.1 final was released today!
- Added new named scopes to support assignments and completed tasks.
- Added sidebar filters for completed tasks.
- Added CSS styles for single-line lists and redesigned task templates.

Thu, Jan 29, 2009
---------------------------------------------------------------------
- Unpacked gem dependencies to /vendor/gems (ruby-openid, haml, and faker).
- Check whether database connection is available in [uses_mysql_uuid] plugin.
- Made task filters work for pending and assigned tasks.

Wed, Jan 28, 2009
---------------------------------------------------------------------
- Implemented task selector to switch between pending, assigned, and completed tasks.
- Major overhaul of task templates to support three task views.
- Changed rake's namespace from [app] to [crm].

Tue, Jan 27, 2009
---------------------------------------------------------------------
- Added sidebar tasks filtering by due date.
- Added CSS styles for selector control.
- Added prototype selector control for tasks.

Mon, Jan 26, 2009
---------------------------------------------------------------------
- Added support for inline forms and added [Create New Task] form.
- Updated task named scopes to evaluate them on each request rather than on server startup.

Sun, Jan 25, 2009
---------------------------------------------------------------------
- Added task categories and due dates to system settings.
- Completed first implementation of Tasks index page.

Sat, Jan 24, 2009
---------------------------------------------------------------------
- Added named scopes for tasks model, created tasks fixtures.
- Two months anniversary ;-).

Fri, Jan 23, 2009
---------------------------------------------------------------------
- Moved permissions related code to [uses_user_permissions] Rails plugin.
- Refactored models to make use of [uses_user_permissions] plugin.
- Moved permission model to [uses_user_permissions] plugin.
- Updated [Task] model and database schema for [Tasks] table.

Thu, Jan 22, 2009
---------------------------------------------------------------------
- Implemented list delete for accounts, campaigns, leads, and opportunities.
- Generated Tasks scaffold.
- Added [Tasks] tab to default settings, renamed [Home] tab to [Dashboard].

Wed, Jan 21, 2009
---------------------------------------------------------------------
- Implemented list delete for contacts.

Tue, Jan 20, 2009
---------------------------------------------------------------------
- Refactored Setting.opportunity_stage to make sure the insertion order is preserved.
- Implemented opportunities filtering by stage.
- Welcome, Mr. President.

Mon, Jan 19, 2009
---------------------------------------------------------------------
- Improved login/logout flash messages.
- Refactored list templates to use collection partials.
- Added sidebar for Campaigns to filter them out by status.

Sun, Jan 18, 2009
---------------------------------------------------------------------
- More fine tuning of plugins and callback hooks.
- Sample plugin now implements view, controller, and controller filter hooks.

Sat, Jan 17, 2009
---------------------------------------------------------------------
- Implemented FatFreeCRM::Plugin and FatFreeCRM::Callback modules.
- Created first sample Fat Free CRM plugin!
- Uninstalled Searchlogic plugin and added Rails Engines.
- Fixed :my scope to use LEFT OUTER JOINs with permissions.

Fri, Jan 16, 2009
---------------------------------------------------------------------
- Experimenting with application plugins.

Thu, Jan 15, 2009
---------------------------------------------------------------------
- Exploring infrastructure for application plugins.

Wed, Jan 14, 2009
---------------------------------------------------------------------
- Added :my named scope for main models to support permissions.
- Refactored all controllers to use :my permission-based scopes.
- Refactored [Leads/Index] and [Leads/Filter] to use collection partial.
- Added missing database indices.

Tue, Jan 13, 2009
---------------------------------------------------------------------
- Added rendering of local sidebar template if it's available.
- Added sidebar for Leads and implemented initial version of leads filtering by status.

Mon, Jan 12, 2009
---------------------------------------------------------------------
- Replaced account template stubs with actual contact and opportunity numbers.
- Added web-to-lead submission hook to Leads controller (thanks bitdigital)!

Sun, Jan 11, 2009
---------------------------------------------------------------------
- Made campaign and lead models track lead-to-opportunity conversion ratio.

Sat, Jan 10, 2009
---------------------------------------------------------------------
- Implemented backend for [Opportunity/New].
- Refactored models validation code.
- Added fixtures for join tables.

Fri, Jan 9, 2009
---------------------------------------------------------------------
- Converted [Opportunity/Show] to HAML and created [Opportunity/New] form (with backend stub).

Thu, Jan 8, 2009
---------------------------------------------------------------------
- Simplified submission for forms with account create/select.
- Added app-specific rake tasks -- app:setup, app:demo, and app:reset.
- Updated [uses_mysql_uuid] plugin to explicitly check for MySQL v5 or later.
- Updated database migrations and rake tasks to make them database-type neutral.
- Fat Free CRM now works with MySQL v4 and SQLite!

Wed, Jan 7, 2009
---------------------------------------------------------------------
- Implemented backend for [Contact/New].
- Made model functions more general for better code reuse.

Tue, Jan 6, 2009
---------------------------------------------------------------------
- Figured out how to make [has_one :through] work and save the join record.
- Restructured [uses_mysql_uuid] to use proper module nesting and extend base with SingletonMethods.
- Fixes in opportunity/index and contact/delete.
- Created [Contact/New] form (with backend stub).
- Moved common JavaScript functions to application namespace.

Mon, Jan 5, 2009
---------------------------------------------------------------------
- Finished refatoring [Lead/Convert].
- Started with index page for contacts.

Sun, Jan 4, 2009
---------------------------------------------------------------------
- Streamlined [Lead/Convert] to make it use objects and default values.
- Added [assigned_to] to accounts and [access] to opportunities.
- Updated [Account/New] form.

Sat, Jan 3, 2009
---------------------------------------------------------------------
- Refactoring of [Lead/Convert] using [fields_for].

Fri, Jan 2, 2009
---------------------------------------------------------------------
- Implemented backend for [Lead/Convert] - create contact along with optional account and opportunity.
- Fixed [uses_mysql_uuid] to work with AR validations.
- Minor database schema changes.

Thu, Jan 1, 2009 -- Happy New Year!
---------------------------------------------------------------------
- Created [account_contacts], [account_opportunities], and [contact_opportunities] join tables.
- Implemented HTML designs and JavaScript for [Lead/Convert] and [Contact/New] forms (with backend stubs).

Wed, Dec 31, 2008
---------------------------------------------------------------------
- More design work on [Lead/Convert] and [Contact/New] forms.

Tue, Dec 30, 2008
---------------------------------------------------------------------
- Added new view/edit/delete icons, started with [Lead/Convert].
- Minor changes in [opportunities] migration.

Mon, Dec 29, 2008
---------------------------------------------------------------------
- More work on opportunity index page.
- Fixed find() class override in [uses_mysql_uuid] plugin.

Sun, Dec 28, 2008
---------------------------------------------------------------------
- Added opportunity stage settings and colors.
- Created opportunities fixtures and started with opportunity index page.

Sat, Dec 27, 2008
---------------------------------------------------------------------
- Added find() override in [uses_mysql_uuid] plugin to make it possible to use find() instead of find_by_uuid().
- Added [contacts] and [opportunities] database migrations.
- Generated [opportunity] scaffold, added [contacts] fixtures.

Fri, Dec 26, 2008
---------------------------------------------------------------------
- Some model and javascript refactoring.
- Another sweep at specs to make them pass with the introduction of UUIDs.

Thu, Dec 25, 2008
---------------------------------------------------------------------
- Update campaign lead count and conversion ratio when creating a new lead.
- Make sure :uuid gets reloaded from the database and not from cached attributes.
- Added extra fields to [User] model and implemented [User/Edit profile].

Wed, Dec 24, 2008
---------------------------------------------------------------------
- Created [uses_mysql_uuid] plugin.
- Converted account, campaign, contact, lead, and user models to use UUIDs.
- Updated controllers to use find_by_uuid() instead of find().
- Updated routes to recognize and extract UUID from URLs.

Tue, Dec 23, 2008
---------------------------------------------------------------------
- Updated controller and view specs.
- Added permissions section to [Lead/New] form.
- Added validation and saving to [Lead] model to actually create new leads.

Mon, Dec 22, 2008
---------------------------------------------------------------------
- Moved form section toggling to application helper and home controller.
- Implemented section toggling in account and campaign forms.
- Added [toll_free_phone] field to accounts.
- Added .top and .req styles for field labels.
- Show/hide form sections based on session where we now store expand/collapse state.

Sun, Dec 21, 2008
---------------------------------------------------------------------
- Redesigned [Lead/New] and revamped related CSS styles.
- Reorganized global settings to make it easier to access them at runtime.
- Toggle sections using link_to_remote() to be able to store toggle status in a session.
- Reveal/hide form sections using toggle/slide visual effect.

Sat, Dec 20, 2008
---------------------------------------------------------------------
- Metallica show at Oakland Coliseum was totally amazing!

Fri, Dec 19, 2008
---------------------------------------------------------------------
- Replaced stub text fields with autocomplete in [Leads/New].

Thu, Dec 18, 2008
---------------------------------------------------------------------
- Implemented ratings JavaScript library to show star ratings.
- Updated [leads] schema, more polishing for [Leads/New] form.

Wed, Dec 17, 2008
---------------------------------------------------------------------
- Added flash confirmation messages for deletes.
- Work on [Leads/New] form (campaign autocomplete, etc.)

Tue, Dec 16, 2008
---------------------------------------------------------------------
- Updated designs for leads, campaigns, and opportunities using left-hand strips.
- Implemented new design for accounts index page.

Mon, Dec 15, 2008
---------------------------------------------------------------------
- More work on leads index page.
- Added leads fixture that uses [faker] gem.
- Restructured status settings to use :label and :color.

Sun, Dec 14, 2008
---------------------------------------------------------------------
- Work on leads schema, model, and fixtures.

Sat, Dec 13, 2008
---------------------------------------------------------------------
- Insalled [annotate_models] plugin and generated model annotations.
- Generated campaign fixtures.
- Updated [Campaign] model to include actual vs. targets.
- Added permissions to [Campaign/New].
- Cleaned up specs and fixtures.

Thu, Dec 11, 2008
---------------------------------------------------------------------
- New tableless design for campaign index page.
- Added new .list CSS styles.
- Made select date popup work with Safari.

Wed, Dec 10, 2008
---------------------------------------------------------------------
- Made calendar_date_select work with field getting focus (campaign/new).
- More work on list of campaigns page.

Tue, Dec 9, 2008
---------------------------------------------------------------------
- Implemented [Campaing/New] with dates validation and status set.

Mon, Dec 8, 2008
---------------------------------------------------------------------
- More work polishing campaigns.
- Added rake task to reset the application (rake app:reset).
- Automatically set focus on first form field.

Sun, Dec 7, 2008
---------------------------------------------------------------------
- Work on [campaigns] database schema and model.
- Started with [Campaigns/New], integrated calendar_date_select for start/end dates.

Sat, Dec 6, 2008
---------------------------------------------------------------------
- Implemented account deletion.
- Fixes for header and signup page layout.

Fri, Dec 5, 2008
---------------------------------------------------------------------
- Installed [advanced_errors] plugin to have full control over the message text.
- Implemented [Account/New] validating account data and preserving submitted form values.
- More work on polishing accounts index page.

Thu, Dec 4, 2008
---------------------------------------------------------------------
- Added Preferences controller stub and header link.
- Updated tabs helper to use global settings to show tabs.
- Updated spec fixtures to use randomly generated dates and counts.
- Converted all layouts to haml.

Wed, Dec 3, 2008
---------------------------------------------------------------------
- Added LICENSE file with the GNU Affero General Public License.
- Fixed auto-generated specs to make them all pass.
- Implemented hash methods for user preferences.

Tue, Dec 2, 2008
---------------------------------------------------------------------
- Added [Setting] and [Preference] models.
- Added [campaigns], [leads], and [contacts] scaffolds.
- Added [config/settings.yml] with default application settings.
- Created [lib/tasks/settings.rake] to load default settings to the database.
- Implemented [Setting] model.

Mon, Dec 1, 2008
---------------------------------------------------------------------
- Created [Permission] polymorphic model, added fixtures to load sample users, accounts, and permissions.

Sun, Nov 30, 2008
---------------------------------------------------------------------
- More work on [accounts] model, CSS styles, and [add account] form.

Sat, Nov 29, 2008
---------------------------------------------------------------------
- Added tabbed and tabless layouts, implemented tabs and current tab tracking.
- Applied CSS styles to all tabless forms (login, sign up, and forgot password).
- Created two column layout for the main contents area.
- Created [Accounts] scaffold and added [Accounts] tab.

Fri, Nov 28, 2008
---------------------------------------------------------------------
- Implemented sign up, login, logout, and forgotten password using [authlogic] plugin.

Wed, Nov 26, 2008
---------------------------------------------------------------------
- Installed [open_id_authentication] plugin.
- Modified [users] table to work with [authlogic] plugin, added tables for openid authentication.

Tue, Nov 25, 2008
---------------------------------------------------------------------
- Installed plugins: [authlogic], [searchlogic], [calendar_date_select], [auto_complete], [in_place_editor], and [haml].

Mon, Nov 24, 2008
---------------------------------------------------------------------
- Added [sessions] and [users] tables, created [User] model.
- Installed Rspec and [acts_as_paranoid] plugins.
- Created the project and posted it on GitHub.
