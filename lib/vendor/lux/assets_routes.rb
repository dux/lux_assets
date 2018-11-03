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

  case nav.root
  when 'compiled_asset'
    path = nav.reset.drop(1).join('/')

    asset = LuxAssets::Element.new path
    current.response.content_type asset.content_type
    current.response.body asset.compile

  when 'raw_asset'
    path = nav.reset.drop(1).join('/')

    Lux.error "You can watch raw files only in development" unless Lux.dev?

    file = Pathname.new path
    body file.exist? ? file.read : "error: File not found"
  end
end
