class ConfirmationsController < Devise::ConfirmationsController
  respond_to :html
  append_view_path 'app/views/devise'
end
