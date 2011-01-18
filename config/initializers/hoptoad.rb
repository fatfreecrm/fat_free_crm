HoptoadNotifier.configure do |config|
  config.api_key = 'a95a20784fd5bce6e8aefba981fd7a99'
  config.js_notifier = true
  config.environment_name = (ENV['HOSTNAME'] =~ /preview/ ? 'preview' : 'live')
end
