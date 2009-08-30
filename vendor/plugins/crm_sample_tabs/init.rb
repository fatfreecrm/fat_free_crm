require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_sample_tabs, initializer) do
          name "Sample Tabs"
        author "Michael Dvorkin"
       version "0.1"
   description "Adds new tabs to Fat Free CRM"
  dependencies :haml

           # The tab syntax is as follows:
           #
           #    tab(:main | :admin, { :text => ..., :url => ... })
           # or
           #    tab(:main | :admin) do |tabs|
           #      ... # add/change/delete tabs
           #    end
           #
           # For example, the following adds new main tab [Apples], which invokes #index in
           # plugin's app/controllers/apples_controller.rb.
           #-----------------------------------------------------------------------------------
           tab :main, :text => "Apples", :url => { :controller => "apples" }

           # If first parameter is :main, it can be omitted. The following example adds new main
           # tab [Oranges], which invokes #index in plugin's app/controllers/oranges_controller.rb.
           #-----------------------------------------------------------------------------------
           tab :text => "Oranges", :url => { :controller => "oranges" }

           # For ultimate control over tabs use block syntax. The following example inserts new
           # Admin tab [Bananas] after the [Users] tab. The [Bananas] tab invokes #index in
           # app/controllers/admin/bananas_controller.rb.
           #-----------------------------------------------------------------------------------
           tab :admin do |tabs|
             tabs.insert(1, { :text => "Bananas", :url => { :controller => "bananas" } })
             #
             # More examples:
             #
             # tabs << tabs.shift                                # <-- Move first tabs to the end of the list.
             # tabs.delete_at(1)                                 # <-- Delete second tab.
             # tabs.delete_if { |tab| tab[:text] == "Settings" } # <-- Delete [Settings] tab.
           end
end
