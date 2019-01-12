# command line helpers

module LuxAssets::Cli
  extend self

  def die text
    text = text.red if text.respond_to?(:red)
    puts text
    puts caller.slice(0, 10)
    exit
  end

  def warn text
    text = text.magenta if text.respond_to?(:magenta)
    puts text
  end

  def info text
    puts text.yellow
  end

  def run what, opts={}
    info (opts[:message] || what)

    stdin, stdout, stderr, wait_thread = Open3.popen3(what)

    error = stderr.gets
    while line = stderr.gets do
      error += line
    end

    # node-sass prints to stderror on complete
    error = nil if error && error.include?('Rendering Complete, saving .css file...')

    if error
      puts '--- command '
      puts what.yellow
      puts '--- error response'
      opts[:cache_file].unlink if opts[:cache_file] && opts[:cache_file].exist?
      warn error
      puts '--- end'
      false
    else
      true
    end
  end

  # monitor for file changes
  def monitor
    puts 'Lux assets - looking for file changes'

    list = LuxAssets
      .to_h
      .values
      .map(&:values)
      .flatten
      .map { |it| Pathname.new it }

    files = list.inject({}) do |h, file|
      if file.to_s.end_with?('.scss')
        # if target file is scss, monitor all child css and scss files
        h[file.to_s] = Dir['%s/**/*' % file.dirname]
          .select { |file| file.end_with?('.scss') || file.end_with?('.css') }
          .map { |it| Pathname.new it }

      else
        # othervise monitor only target file
        h[file.to_s] = [file]
      end

      h
    end

    last_change = Time.now

    while true
      changed = false

      for key, values in files
        for file in values
          if file.mtime > last_change
            changed = true
            LuxAssets.compile key, force: true
          end
        end
      end

      last_change = Time.now if changed

      sleep 2
    end
  end
end