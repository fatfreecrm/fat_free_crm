require 'action_controller'
require 'authlogic'

# Fix bug for default cookie name (use klass_name, instead of guessed_klass_name)
# Pull request pending: https://github.com/binarylogic/authlogic/pull/281
Authlogic::Session::Base.instance_eval do
  def cookie_key(value = nil)
    rw_config(:cookie_key, value, "#{klass_name.underscore}_credentials")
  end
end

