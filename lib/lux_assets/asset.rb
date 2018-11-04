# Asset group, single asset that produces target css or js

class LuxAssets::Asset

  def initialize ext, name
    raise ArgumentError.new('name not deinfed') if name.empty?
    @ext    = ext.to_sym == :js ? :js : :css
    @name   = name.to_s
    @files  = LuxAssets.to_h[@ext][@name]
    @target = "#{@ext}/#{@name}"
  end

  def js?
    @ext == :js
  end

  def css?
    @ext == :css
  end

  def compile
    @data = []

    LuxAssets::Cli.die "No files found for [#{@ext}/#{@name}]" unless @files[0]

    for file in @files
      if file.is_a?(Proc)
        @data.push file.call
      else
        @data.push LuxAssets.compile file, production: true
      end
    end

    send 'compile_%s' % @ext

    @asset_file
  end

  def files
    @files
  end

  ###

  private

  # add sha1 tag to referenced files in css
  def tag_public_assets
    data = @asset_path.read
    data = data.gsub(/url\(([^\)]+)\)/) do
      if $1.include?('data:') || $1.include?('#') || $1.include?('?') || $1.include?('::')
        'url(%s)' % $1
      else
        path = $1.gsub(/^['"]|['"]$/, '')
        path = path[0,1] == '/' ? Pathname.new('./public%s' % path) : Pathname.new('./public/assets').join(path)

        if path.exist?
          'url("%s?%s")' % [path.to_s.sub('./public', ''), Digest::SHA1.hexdigest(path.read)[0, 6]]
        else
          LuxAssets::Cli.warn 'Resource "%s" referenced in "%s/%s" but not found' % [path, @ext, @name]
          'url("%s")' % path
        end
      end
    end

    @asset_path.write data
  end

  def save_data data
    @asset_file = '/assets/%s' % (@target.sub('/', '-') + '-' + Digest::SHA1.hexdigest(data) + '.' + @ext.to_s)
    @asset_path = Pathname.new "./public#{@asset_file}"

    if LuxAssets::Manifest.add(@target, @asset_file)
      @asset_path.write data
      yield
    end
  end

  def compile_js
    save_data @data.join(";\n") do
      # babel fix and minify
      command = 'node_modules/babel-cli/.bin/babel --minified --no-comments --compact true -o "%{file}" "%{file}"' % { file: @asset_path }
      LuxAssets::Cli.run command, message: "Babel filter and minify: #{@asset_path}"
    end
  end

  def compile_css
    save_data @data.join($/) do
      tag_public_assets

      #autoprefixer
      LuxAssets::Cli.run './node_modules/.bin/autoprefixer-cli %s' % @asset_path, message: "Autoprefixer: #{@asset_path}"
    end
  end
end