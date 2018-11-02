# libs
require 'digest/sha1'
require 'json'
require 'pathname'
require 'open3'

# gem files
require_relative './lux_assets/base'
require_relative './lux_assets/asset'
require_relative './lux_assets/element'
require_relative './lux_assets/manifest'

# lux framework bindings
if defined?(Lux)
  require_relative './vendor/lux/assets_helper'
  require_relative './vendor/lux/assets_plugin'
  require_relative './vendor/lux/assets_routes'
end

# rake bindings
if defined?(Rake)
  require_relative './vendor/tasks.rb'
end

# create needed dirs unless found
for dir in ['./tmp/', './tmp/assets', './public', './public/assets']
  Dir.mkdir(dir) unless Dir.exist?(dir)
end

