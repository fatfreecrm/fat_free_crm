Ransack.configure do |config|
  config.default_predicates = {
    :compounds => false,
    :only => [
      :cont, :not_cont, :blank, :present, :true, :false, :null, :not_null,
      :matches, :does_not_match, :eq, :not_eq, :lt, :gt
    ]
  }

  config.ajax_options = {
    :url  => '/:controller/auto_complete.json',
    :type => 'POST',
    :key  => 'auto_complete_query'
  }
end