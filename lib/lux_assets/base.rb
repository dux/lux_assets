# Main assets module

module LuxAssets
  extend self

  CONFIG_PATH = Pathname.new ENV.fetch('ASSETS_CONFIG') { './config/assets.rb' }

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

  def asset name
    @name = name.to_s
    yield
  end

  def configure &block
    class_eval &block
  end

  def js name=nil, &block
    add_files :js, name, &block
  end

  def css name=nil, &block
    add_files :css, name, &block
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
        LuxAssets::Cli.die 'No files found in "%s -> :%s" (%s)'.red % [@ext, @name, added]
      end
    end
  end

  # get list of files in the resource
  def files ext, name=nil
    ext, name = ext.split('/', 2) unless name
    ext = ext.to_sym

    raise ArgumentError.new('name not deinfed') if name.empty?

    to_h[ext][name.to_s]
  end

  # compile single asset
  def compile path
    LuxAssets::Element.new(path).compile
  end

  # compile all assets
  def compile_all
    # generate master file for every resource
    for ext in [:js, :css]
      for name in to_h[ext].keys
        path = LuxAssets.send(ext, name).compile
        yield "#{ext}/#{name}", path if block_given?
      end
    end

    # gzip if needed
    files = Dir['./public/assets/*.css'] + Dir['./public/assets/*.js']
    files.each do |file|
      LuxAssets::Cli.run 'gzip -k %s' % file unless File.exist?('%s.gz' % file)
    end

    # touch all files and reset the timestamp
    Dir['./public/assets/*']
      .each { |file| system 'touch -t 201001010101 %s' % file }
  end

  # get all files as a hash
  def to_h
    unless @assets_loaded
      LuxAssets::Cli.die 'Assets file not found in %s' % CONFIG_PATH unless CONFIG_PATH.exist?
      @assets_loaded = true
      eval CONFIG_PATH.read
    end

    @assets
  end

  # show files and file sizes
  def examine
    data = to_h.dup
    data.each do |ext, value_hash|
      puts ext.to_s.upcase.green
      value_hash.each do |key, files|
        puts '  %s' % key.green

        total = 0

        files.each_with_index do |file, i|
          if File.exist?(file)
            size  = File.size(file)
            total += size
            puts '  %s kB - %s' % [(size/1024.to_f).round(1).to_s.rjust(6), file]
          else
            puts '  %s' % file
          end
        end

        total = '%s kB in total' % (total/1024.to_f).round(1).to_s
        puts total.rjust(20)
      end
    end
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

  def add_files ext, name=nil, &block
    if block_given?
      @files = []
      @ext   = ext
      class_eval &block
      @assets[ext][@name] = @files
    else
      Asset.new ext, name
    end
  end
end