// JS import

// TODO:
/*
  import 'jquery-migrate/dist/jquery-migrate.min'
  have that issue https://github.com/jquery/jquery-migrate/issues/287
*/

// Node modules import
import $ from 'jquery/dist/jquery.min';
global.$ = global.jQuery = $;
import './js/browser_fix'
import 'jquery-ujs/src/rails';
import 'webpack-jquery-ui'; // CSS and JS for jquery-ui here
import 'select2/dist/js/select2.full.min';

// Vendor js import
import 'javascripts/autocomplete-rails'
import 'javascripts/jquery.disable';
import 'javascripts/jquery_timeago';
import 'javascripts/jquery_ui_datepicker/jquery-ui-timepicker-addon';
import 'javascripts/textarea_autocomplete';
import 'javascripts/ransack/predicates'
import 'javascripts/ransack_ui_jquery/search_form'

// Application js import
import './js/timeago.coffee';
import './js/admin.coffee';
import './js/crm.coffee';
import './js/crm_classes.coffee';
import './js/crm_comments.coffee';
import './js/crm_loginout.coffee';
import './js/crm_select2.coffee';
import './js/crm_sortable.coffee';
import './js/crm_tags.coffee';
import './js/crm_textarea_autocomplete.coffee';
import './js/datepicker.coffee';
import './js/format_buttons.coffee';
import './js/lists.coffee';
import './js/pagination.coffee';
import './js/search.coffee';


// CSS import
import './styles/app';
