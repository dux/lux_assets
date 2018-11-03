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

  def run what, cache_file=nil
    puts what.yellow

    stdin, stdout, stderr, wait_thread = Open3.popen3(what)

    error = stderr.gets
    while line = stderr.gets do
      error += line
    end

    # node-sass prints to stderror on complete
    error = nil if error && error.include?('Rendering Complete, saving .css file...')

    if error
      cache_file.unlink if cache_file && cache_file.exist?
      warn error
    end
  end

  # monitor for file changes
  def monitor
    puts 'Lux assets - looking for file changes'

    files       = LuxAssets.to_h.values.map(&:values).flatten.map { |it| Pathname.new it }
    last_change = Time.now

    while true
      for file in files
        if file.mtime > last_change
          last_change = Time.now
          LuxAssets.compile file.to_s
        end
      end

      sleep 2
    end
  end
end