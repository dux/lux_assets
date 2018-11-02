# One file that can be scss, js, coffee, ts, etc...
class LuxAssets::Element
  TMP_ASSETS = './tmp/assets'

  def initialize source, opts={}
    @source = Pathname.new source
    @opts   = opts
    @cache = Pathname.new './tmp/assets/%s' % source.gsub('/','-')
  end

  def compile
    method_name = 'compile_%s' % @source.to_s.split('.').last.downcase

    if respond_to?(method_name, true)
      cached || send(method_name)
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
    defined?(Rake)
  end

  def cached
    @cache.exist? && (@cache.ctime > @source.ctime) ? @cache.read : false
  end

  def compile_coffee
    coffee_path = './node_modules/coffee-script/bin/coffee'
    coffee_opts = production? ? '-cp' : '-Mcp --no-header'

    LuxAssets.run "#{coffee_path} #{coffee_opts} '#{@source}' > '#{@cache}'", @cache

    data = @cache.read
    data = data.gsub(%r{//#\ssourceURL=[\w\-\.\/]+/app/assets/}, '//# sourceURL=/raw_asset/')

    @cache.write data

    data
  end

  def compile_scss
    node_sass = './node_modules/node-sass/bin/node-sass'
    node_opts = production? ? '--output-style compressed' : '--source-comments'
    LuxAssets.run "#{node_sass} #{node_opts} '#{@source}' '#{@cache}'", @cache
    @cache.read
  end
  alias :compile_sass :compile_scss

  def compile_js
    ";\n%s\n;" % @source.read
  end

  def compile_ts
    LuxAssets.run "node_modules/typescript/.bin/tsc --outFile '#{@cache}' '#{@source}'"
  end

end