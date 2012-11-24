
# Register the views that FatFreeCRM provides
#------------------------------------------------------------------------------

[ {:name => 'contacts_index_brief', :title => 'Brief format', :icon => 'brief.png',
   :controllers => ['contacts'], :actions => ['index'], :template => 'contacts/index_brief'},
  {:name => 'contacts_index_long', :title => 'Long format', :icon => 'long.png',
   :controllers => ['contacts'], :actions => ['index'], :template => 'contacts/index_long'}, # default index view
  {:name => 'contacts_index_full', :title => 'Full format', :icon => 'full.png',
   :controllers => ['contacts'], :actions => ['index'], :template => 'contacts/index_full'},
  {:name => 'contacts_show_normal', :title => 'Normal format', :icon => 'long.png',
   :controllers => ['contacts'], :actions => ['show'], :template => nil}, # default show view

 {:name => 'opportunities_index_brief', :title => 'Brief format', :icon => 'brief.png',
  :controllers => ['opportunities'], :actions => ['index'], :template => 'opportunities/index_brief'},
 {:name => 'opportunities_index_long', :title => 'Long format', :icon => 'long.png',
   :controllers => ['opportunities'], :actions => ['index'], :template => 'opportunities/index_long'}, # default
 {:name => 'opportunities_show_normal', :title => 'Normal format', :icon => 'long.png',
   :controllers => ['opportunities'], :actions => ['show'], :template => nil}, # default show view
   
 {:name => 'accounts_index_brief', :title => 'Brief format', :icon => 'brief.png',
  :controllers => ['accounts'], :actions => ['index'], :template => 'accounts/index_brief'}, # default
 {:name => 'accounts_index_long', :title => 'Long format', :icon => 'long.png',
  :controllers => ['accounts'], :actions => ['index'], :template => 'accounts/index_long'}, # default
 {:name => 'accounts_show_normal', :title => 'Normal format', :icon => 'long.png',
   :controllers => ['accounts'], :actions => ['show'], :template => nil}, # default show view
 
 {:name => 'leads_index_brief', :title => 'Brief format', :icon => 'brief.png',
  :controllers => ['leads'], :actions => ['index'], :template => 'leads/index_brief'}, # default
 {:name => 'leads_index_long', :title => 'Long format', :icon => 'long.png',
  :controllers => ['leads'], :actions => ['index'], :template => 'leads/index_long'},
 {:name => 'leads_show_normal', :title => 'Normal format', :icon => 'long.png',
   :controllers => ['leads'], :actions => ['show'], :template => nil}, # default show view
  
 {:name => 'campaigns_index_brief', :title => 'Brief format', :icon => 'brief.png',
  :controllers => ['campaigns'], :actions => ['index'], :template => 'campaigns/index_brief'}, # default
 {:name => 'campaigns_index_long', :title => 'Long format', :icon => 'long.png',
  :controllers => ['campaigns'], :actions => ['index'], :template => 'campaigns/index_long'},
 {:name => 'campaigns_show_normal', :title => 'Normal format', :icon => 'long.png',
   :controllers => ['campaigns'], :actions => ['show'], :template => nil}, # default show view
 
].each {|view| FatFreeCRM::ViewFactory.new(view)}
