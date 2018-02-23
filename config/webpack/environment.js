const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const erb =  require('./loaders/erb');
const coffee =  require('./loaders/coffee');
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      jquery: "jquery",
      "window.jQuery": "jquery'",
      "window.$": "jquery"
  })
);
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});
environment.loaders.append('coffee', coffee);
environment.loaders.append('erb', erb);
module.exports = environment;
