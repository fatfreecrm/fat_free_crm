Ransack.configure do |config|
  config.default_predicates = {
    :compounds => false,
    :only => [
      :cont, :not_cont, :blank, :present, :null, :not_null,
      :matches, :does_not_match, :eq, :not_eq, :lt, :gt, :true, :false
    ]
  }
end