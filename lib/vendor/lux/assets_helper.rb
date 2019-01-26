# export to all templates
# = asset 'www/index.scss'
# = asset 'www/index.coffee'
module HtmlHelper
  def asset_include path, opts={}
    raise ArgumentError.new("Asset path can't be empty") if path.empty?

    ext   = path.split('?').first.split('.').last
    type  = ['css', 'sass', 'scss'].include?(ext) ? :style : :script
    type  = :style if path.include?('fonts.googleapis.com')

    current.response.early_hints path, type

    data = {}

    data[:crossorigin] = opts[:crossorigin] || :anonymous
    data[:integrity]   = opts[:integrity] if opts[:integrity]

    if type == :style
      data[:media] = opts[:media] || :all
      data[:rel]   = :stylesheet
      data[:href]  = path
      data.tag :link
    else
      data[:src] = path
      data.tag :script
    end
  end

  # builds full asset path based on resource extension
  # asset('js/main')
  # will render 'app/assets/js/main/index.coffee' as http://aset.path/assets/main-index-md5hash.js
  def asset file, opts={}
    opts = { dev_file: opts } unless opts.class == Hash

    # return internet links
    return asset_include file if file.starts_with?('/') || file.starts_with?('http')

    if Lux.config(:compile_assets)
      # return second link if it is defined and we are in dev mode
      return asset_include opts[:dev_file] if opts[:dev_file]

      # try to create list of incuded files and show every one of them
      files = LuxAssets.files(file) || []
      data = files.inject([]) do |total, asset|
        if asset.is_a?(Proc)
          tag_name = file.include?('css') ? :style : :script
          total.push({}.tag tag_name, asset.call)
        else
          total.push asset_include '/compiled_asset/' + asset
        end
      end

      data.map{ |it| it.sub(/^\s\s/,'') }.join("\n")
    else
      # return asset link in production or fail unless able
      manifest = Lux.ram_cache('asset-manifest') { JSON.load Lux.root.join('public/manifest.json').read }
      mfile    = manifest['files'][file]

      if mfile.empty?
        unless opts[:raise].is_a?(FalseClass)
          raise 'Compiled asset link for "%s" not found in manifest.json' % file
        end

        nil
      else
        opts[:integrity] = manifest['integrity'][file]
        return asset_include(Lux.config.assets_root.to_s + mfile, opts)
      end
    end
  end

  # assets :vendor, :main
  def assets *args
    total = []
    [:css, :js].each do |ext|
      args.map do |group|
        data = asset("#{ext}/#{group}", raise: false)
        total.push data if data.present?
      end
    end
    total.join($/)
  end

end