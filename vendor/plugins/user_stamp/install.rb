instructions = <<EOF

#{'*' * 62}
Don't forget to add user stamp to your application controller.
  
  class ApplicationController < ActionController::Base
    user_stamp Post, Asset, Job
  end

View the README for more information.
#{'*' * 62}

EOF

puts instructions