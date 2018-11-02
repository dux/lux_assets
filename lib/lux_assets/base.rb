# LuxAssets.configure do
#   asset :admin do
#     js do
#       add 'js/admin/js_vendor/*'
#       add 'js/admin/js/*'
#       add 'js/shared/*'
#       add 'js/admin/index.coffee'
#     end
#     css do
#       add 'css/admin/index.scss'
#     end
#   end
# end
# ...

# LuxAssets.css('admin').files
# LuxAssets.css(:admin).compile

# LuxAssets.css(:admin).compile_all do |name, path|
#   puts "Compile #{name} -> #{path}"
# end

module LuxAssets
  extend self

  CONFIG_PATH = Pathname.new ENV.fetch('ASSET_CONFIG') { './config/assets.rb' }

  ASSET_TYPES ||= {
    js:  ['js', 'coffee', 'ts'],
    css: ['css', 'scss']
  }

  @assets  ||= { js: {}, css: {} }

  @relative_root = './app/assets'
  def relative_root name=nil
    @relative_root = name if name
    @relative_root
  end

  def die text
    puts text
    exit
  end

  def asset name
    @name = name.to_s
    yield
  end

  def configure &block
    class_eval &block
  end

  def run what, cache_file=nil
    puts what.yellow

    stdin, stdout, stderr, wait_thread = Open3.popen3(what)

    error = stderr.gets
    while line = stderr.gets do
      error += line
    end

    # node-sass prints to stderror on complete
    error = nil if error && error.index('Rendering Complete, saving .css file...')

    if error
      cache_file.unlink if cache_file && cache_file.exist?

      puts error.red
    end
  end

  def js name=nil, &block
    add_files :js, name, block
  end

  def css name=nil, &block
    add_files :css, name, block
  end

  # adds file or list of files
  # add 'plugin:js_widgets/*'
  # add 'js/vendor/*'
  # add 'index.coffee'
  # add proc { ... }
  def add added
    case added
    when Array
      add_local_files added
      return
    when Proc
      @files += [added]
    else
      files =
      if added[0,1] == '/' || added[0,2] == './'
        added
      else
        "#{@relative_root}/#{added}"
      end

      files =
      if files.include?('*')
        files += '/*' if files =~ %r{\/\*\*$}
        Dir[files].sort
      else
        [files]
      end

      files = files.select { |it| File.file?(it) }

      if files[0]
        add_local_files files
      else
        die 'No files found in "%s -> :%s" (%s)'.red % [@ext, @name, added]
      end
    end
  end

  # get list of files in the resource
  def files name
    parts = name.split('/', 2)
    to_h[parts.first.to_sym][parts[1]]
  end

  def compile_all
    for ext in [:js, :css]
      for name in to_h[ext].keys
        path = LuxAssets.send(ext, name).compile

        yield "#{ext}/#{name}", path if block_given?
      end
    end
  end

  def to_h
    unless @assets_loaded
      die 'Assets file not found in %s' % CONFIG_PATH unless CONFIG_PATH.exist?
      @assets_loaded = true
      eval CONFIG_PATH.read
    end

    @assets
  end

  private

  def add_local_files files
    files = files.select { |it| ASSET_TYPES[@ext].include?(it.split('.').last) }

    files = files.select do |f|
      name = f.split('/').last
      name.include?('.') && !name[0, 1] != '!'
    end

    @files += files
    files
  end

  def add_files ext, name, block
    @name = name.to_s if name
    return Asset.new ext, @name unless block

    @files = []
    @ext   = ext
    class_eval &block
    @assets[ext][@name] = @files
  end
end