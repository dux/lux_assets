# One file that can be scss, js, coffee, ts, etc...

class LuxAssets::Element
  def initialize source
    @source = Pathname.new source

    source  = source.sub(/^\.\//, '').sub(/^\//, '').gsub('/', '-')
    source  = '%s-%s' % [production? ? :p : :d, source] if content_type == 'text/css'
    @cache  = Pathname.new './tmp/assets/%s' % source
  end

  def compile force:nil
    method_name = 'compile_%s' % @source.to_s.split('.').last.downcase

    if respond_to?(method_name, true)
      (!force && cached) || send(method_name)
    else
      @source.read
    end
  end

  def content_type
    @ext ||= @source.to_s.split('.').last.to_sym
    [:css, :scss].include?(@ext) ? 'text/css' : 'text/javascript'
  end

  ###

  private

  def production?
    # if building from Rake then we are compiling for production
    defined?(Rake) || ENV['ASSETS_ENV'] == 'production'
  end

  def cached
    @cache.exist? && (@cache.ctime > @source.ctime) ? @cache.read : false
  end

  def compile_coffee
    coffee_path = './node_modules/coffee-script/bin/coffee'
    coffee_opts = production? ? '-cp' : '-Mcp --no-header'

    if LuxAssets::Cli.run("#{coffee_path} #{coffee_opts} '#{@source}' > '#{@cache}'", cache_file: @cache, message: "Compile Coffee: #{@source}")
      data = @cache.read
      data = data.gsub(%r{//#\ssourceURL=[\w\-\.\/]+/app/assets/}, '//# sourceURL=/raw_asset/')

      @cache.write data

      data
    else
      nil
    end
  end

  def compile_scss
    node_sass = './node_modules/node-sass/bin/node-sass'
    node_opts = production? ? '--output-style compressed' : '--source-comments'
    LuxAssets::Cli.run "#{node_sass} #{node_opts} '#{@source}' '#{@cache}'", cache_file: @cache, message: "Compile SCSS: #{@source}"
    @cache.read
  end
  alias :compile_sass :compile_scss
  alias :compile_css :compile_sass

  def compile_js
    ";\n%s\n;" % @source.read
  end

  def compile_ts
    LuxAssets::Cli.run "node_modules/typescript/.bin/tsc --outFile '#{@cache}' '#{@source}'", cache_file: @cache, message: "Compile TypeScript: #{@source}"
  end

end