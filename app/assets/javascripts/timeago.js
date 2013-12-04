// Run function on page load
jQuery(document).ready(function() {
  jQuery.timeago.settings.allowFuture = true;
  // our modification to choose correct language
  jQuery.timeago.settings.strings = jQuery.timeago.settings.locales[crm.language]
  jQuery("span.timeago").timeago();
  // update every minute
  setInterval(function(){ jQuery("span.timeago").timeago(); }, 60000);
});

// Run after jQuery ajax event
jQuery(document).ajaxComplete( function() { jQuery("span.timeago").timeago(); } );

// Run after prototype ajax event
Ajax.Responders.register( {
  onComplete: function(response) { jQuery("span.timeago").timeago(); }
})
