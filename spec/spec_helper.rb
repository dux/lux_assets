ENV['RACK_ENV']        = 'test'
ENV['ASSETS_CONFIG']   = './spec/assets/assets.rb'
ENV['ASSETS_MANIFEST'] = './spec/assets/manifest.json'

system "RACK_ENV=test bin/lux_assets install" unless Dir.exist?('./node_modules')

File.delete ENV['ASSETS_MANIFEST'] if File.exist? ENV['ASSETS_MANIFEST']

require 'awesome_print'

# load lux
require_relative '../lib/lux_assets.rb'

class Object
  def rr data
    ap ['- start', data, '- end']
  end
end

# basic config
RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :json, CustomFormatterClass
end
