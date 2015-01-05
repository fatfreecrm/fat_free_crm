# silence sanitize_sql_hash_for_conditions warning from cancancan hopefully
# this will be in https://github.com/CanCanCommunity/cancancan/pull/155

if Rails.env.test?
  ActiveSupport::Deprecation.behavior = lambda do |msg, stack|
    unless /sanitize_sql_hash_for_conditions/ =~ msg
      ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:stderr].call(msg,stack)
    end
  end
end
