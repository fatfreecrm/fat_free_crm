Ransack.configure do |config|
  config.default_predicates = {
    :compounds => false,
    :only => [
      :cont, :not_cont, :blank, :present, :true, :false, :eq, :not_eq,
      :lt, :gt, :null, :not_null, :matches, :does_not_match
    ]
  }

  config.ajax_options = {
    :url  => '/:controller/auto_complete.json',
    :type => 'POST',
    :key  => 'auto_complete_query'
  }
end