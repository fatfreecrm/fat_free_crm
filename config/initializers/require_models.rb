#
# We need to require our models here, since they are organized in subdirectories.
# If we don't do this, is_paranoid raises the following error when running tests:
#
#     super from singleton method that is defined to multiple classes is not supported;
#     this will be fixed in 1.9.3 or later
#
Dir[Rails.root.join("app/models/**/*.rb")].each {|f| require f }

