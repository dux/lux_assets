# Asset group, single asset that produces target css or js

class LuxAssets::Asset
  PUBLIC_ASSETS = './public/assets'

  def initialize ext, name
    @ext    = ext == :js ? :js : :css
    @name   = name
    @files  = LuxAssets.to_h[ext][name]
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

    die "No files found for [#{@ext}/#{@name}]" unless @files[0]

    for file in @files
      if file.is_a?(Proc)
        @data.push file.call
      else
        @data.push LuxAssets::Element.new(file).compile
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

  def save_data data
    @asset_file = '/assets/%s' % (@target.sub('/', '-') + '-' + Digest::SHA1.hexdigest(data) + '.' + @ext.to_s)
    @asset_path = "./public#{@asset_file}"

    File.write(@asset_path, data)

    if LuxAssets::Manifest.add(@target, @asset_file)
      yield

      LuxAssets.run 'touch -t 201001010101 %s' % @asset_path
      LuxAssets.run 'gzip -k %s' % @asset_path
    end
  end

  def compile_js
    save_data @data.join(";\n") do
      # babel fix and minify
      LuxAssets.run 'node_modules/babel-cli/.bin/babel --minified --no-comments --compact true -o "%{file}" "%{file}"' % { file: @asset_path }
    end
  end

  def compile_css
    save_data @data.join($/) do
      #autoprefixer
      LuxAssets.run './node_modules/.bin/autoprefixer-cli %s' % @asset_path
    end
  end
end