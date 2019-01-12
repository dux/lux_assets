# /compiled_asset/www/js/pjax.coffee
# /raw_asset/www/js/pjax.coffee
Lux.app.before do
  next unless nav.path[1]
  next unless Lux.config(:compile_assets)

  # only allow clear in dev
  # clear assets every 4 seconds max
  if Lux.current.no_cache?
    Lux.cache.fetch('lux-clear-assets', ttl: 4, log: false, force: false) do
      puts '* Clearing assets from ./tmp/assets'.yellow
      `rm -rf ./tmp/assets && mkdir ./tmp/assets`
      true
    end
  end

  _, root, asset_path = Lux.current.request.path.split('/', 3)

  case root
  when 'compiled_asset'
    asset = LuxAssets::Element.new asset_path
    current.response.content_type asset.content_type
    current.response.body asset.compile

  when 'raw_asset'
    Lux.error "You can watch raw files only in development" unless Lux.dev?

    file = Pathname.new asset_path
    body file.exist? ? file.read : "error: File not found"
  end
end

# additional info for "lux config" cli
Lux.app.info do
  puts
  puts 'assets:'
  for ext in LuxAssets.to_h.keys
    for key, value in LuxAssets.to_h[ext]
      name = '  LuxAsset.%s(:%s)' % [ext, key]
      print name.ljust(35)
      puts ' - %s' % value.length.pluralize(:file)
    end
  end
end

# include files from a plugin
module LuxAssets
  def plugin name
    # load pluigin if needed
    Lux.plugin name

    plugin = Lux.plugin.get name
    add '%s/**' % plugin[:folder]
  end
end

