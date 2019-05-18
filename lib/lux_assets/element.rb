# One file that can be scss, js, coffee, ts, etc...

require 'erb'

class LuxAssets::Element

  def initialize source
    @source = @cache_source = Pathname.new source

    @target  = source.sub(/^\.\//, '').sub(/^\//, '').gsub('/', '-')
    @target  = '%s-%s' % [@production ? :p : :d, @target] if content_type == 'text/css'
    @cache  = Pathname.new './tmp/assets/%s' % @target
  end

  def content_type
    @ext ||= @source.to_s.split('.').last.to_sym
    [:css, :scss].include?(@ext) ? 'text/css' : 'text/javascript'
  end

  # use LuxAsset.compile if possible
  def compile force:nil, production:nil
    @production = production || false
    method_name = 'compile_%s' % @source.to_s.split('.').last.downcase

    if respond_to?(method_name, true)
      (!force && cached) || ( process_erb; send(method_name))
    else
      @source.read
    end
  end

  ###

  private

  def cached
    @cache.exist? && (@cache.ctime > @cache_source.ctime) ? @cache.read : false
  end

  def process_erb
    data = @source.read
    if data.include?('<%=') && data.include?('%>')
      LuxAssets::Cli.info 'Compile ERB: %s' % @source
      @source = Pathname.new './tmp/assets/erb-' + @target
      @source.write ERB.new(data).result
    end
  end

  def compile_coffee
    coffee_path = './node_modules/coffeescript/bin/coffee'
    coffee_opts = @production ? '-cp' : '-Mcp --no-header'

    cmd = "#{coffee_path} #{coffee_opts} '#{@source}' > '#{@cache}'"
    # cmd = "#{coffee_path} #{coffee_opts} '#{@source}' | ./node_modules/.bin/babel --plugins babel-plugin-transform-react-jsx -o '#{@cache}'"

    if LuxAssets::Cli.run(cmd, cache_file: @cache, message: "Compile Coffee: #{@source}")
      data = @cache.read
      data = data.gsub(" sourceURL=#{Lux.root}/", " sourceURL=/raw_asset/")

      @cache.write data

      data
    else
      nil
    end
  end

  def compile_scss
    node_sass = './node_modules/node-sass/bin/node-sass'
    node_opts = @production ? '--output-style compressed' : '--source-comments'
    LuxAssets::Cli.run "#{node_sass} #{node_opts} '#{@source}' '#{@cache}'", cache_file: @cache, message: "Compile SCSS: #{@source}"
    @cache.read
  end
  alias :compile_sass :compile_scss
  alias :compile_css :compile_sass

  def compile_js
    ";\n%s\n;" % @source.read
  end

  def compile_ts
    LuxAssets::Cli.run "./node_modules/typescript/.bin/tsc --outFile '#{@cache}' '#{@source}'", cache_file: @cache, message: "Compile TypeScript: #{@source}"
  end

end