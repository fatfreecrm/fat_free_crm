require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_sample_tabs, initializer) do
          name "Sample Tabs"
        author "Michael Dvorkin"
       version "0.1"
   description "Adds new tabs to Fat Free CRM"
  dependencies :haml

           # The tab syntax is as follows: tab(:main | :admin, { :text => ?, :url => ? })
           # For example, the following adds new main tab [Apples], which invokes #index in
           # plugin's app/controllers/apples_controller.rb.
           #-----------------------------------------------------------------------------------
           tab :main, :text => "Apples", :url => { :controller => "apples" }

           # If first parameter is :main, it can be omitted. The following adds new main tab
           # [Oranges], which invokes #index in plugin's app/controllers/oranges_controller.rb.
           #-----------------------------------------------------------------------------------
           tab :text => "Oranges", :url => { :controller => "oranges" }

           # For ultimate control over tabs use block syntax. The following adds new Admin
           # tab [Bananas], and moves he first tab to the end of the list. The [Bananas] tab
           # invokes #index in app/controllers/admin/bananas_controller.rb.
           #-----------------------------------------------------------------------------------
           tab :admin do |tabs|
             tabs << { :text => "Bananas", :url => { :controller => "bananas" } }
             tabs << tabs.shift
             # tabs.delete_at(1) # <-- Delete second tab.
             # tabs.delete_if { |tab| tab[:text] == "Settings" } # <-- Delete [Settings] tab.
           end
end
