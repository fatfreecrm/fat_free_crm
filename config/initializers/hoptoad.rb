HoptoadNotifier.configure do |config|
  config.api_key = 'a95a20784fd5bce6e8aefba981fd7a99'
  config.environment_name = 'preview' if Rails.env == 'production' and ENV['HOSTNAME'] =~ /preview/
end
