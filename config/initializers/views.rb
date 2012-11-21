
# Register the views that FatFreeCRM provides
#------------------------------------------------------------------------------

[ {:name => 'contacts_index_brief', :title => 'Brief format', :icon => 'brief.png',
   :controllers => ['contacts'], :actions => ['index'], :template => 'contacts/index_brief'},
  {:name => 'contacts_index_long', :title => 'Long format', :icon => 'long.png',
   :controllers => ['contacts'], :actions => ['index'], :template => nil}, # default
  {:name => 'contacts_index_full', :title => 'Full format', :icon => 'full.png',
   :controllers => ['contacts'], :actions => ['index'], :template => 'contacts/index_full'},

 {:name => 'opportunities_index_normal', :title => 'Normal format', :icon => 'long.png',
  :controllers => ['opportunities'], :actions => ['index'], :template => nil}, # default
   
 {:name => 'accounts_index_normal', :title => 'Normal format', :icon => 'long.png',
  :controllers => ['accounts'], :actions => ['index'], :template => nil}, # default
 
 {:name => 'leads_index_normal', :title => 'Normal format', :icon => 'long.png',
  :controllers => ['leads'], :actions => ['index'], :template => nil}, # default
  
 {:name => 'campaigns_index_normal', :title => 'Normal format', :icon => 'long.png',
  :controllers => ['campaigns'], :actions => ['index'], :template => nil}, # default
 
].each {|view| FatFreeCRM::ViewFactory.new(view)}
