# command line helpers

module LuxAssets::Cli
  extend self

  def die text
    puts text.try(:red)
    exit
  end

  def warn text
    puts text.try(:magenta)
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
end