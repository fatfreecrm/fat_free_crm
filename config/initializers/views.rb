
# Register the views that FatFreeCRM provides
#------------------------------------------------------------------------------

[{:name => 'brief', :title => 'Brief format', :icon => 'brief.png',
  :controllers => ['contacts'], :actions => ['show', 'index']},
 {:name => 'long', :title => 'Long format', :icon => 'long.png',
  :controllers => ['contacts'], :actions => ['show', 'index']},
 {:name => 'full', :title => 'Full format', :icon => 'full.png',
  :controllers => ['contacts'], :actions => ['show', 'index']},
].each {|view| FatFreeCRM::ViewFactory.new(view)}
