const { environment } = require('@rails/webpacker')

// Include jQuery & popper.js: =================================================
const webpack = require('webpack')

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
// =============================================================================

module.exports = environment
