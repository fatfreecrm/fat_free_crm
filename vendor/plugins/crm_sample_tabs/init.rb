require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_sample_tabs, initializer) do
          name "Sample Tabs"
        author "Michael Dvorkin"
       version "0.1"
   description "Adds new tabs to Fat Free CRM"
  dependencies # None.

               # Calling tab without a block adds a new tab.
           tab :main, :text => "Apples", :url => { :controller => "apples" }
           tab :main, :text => "Oranges", :url => { :controller => "oranges" }
           
               # Calling tab with the block provides total control.
           tab :admin do |tabs|
             tabs << [ :text => "Bananas", :url => { :controller => "bananas" } ]
             tabs << tabs.shift
             # tabs.delete_at(1)
           end
end
