# http://stackoverflow.com/questions/5159607/rails-engine-gems-dependencies-how-to-load-them-into-the-application

Gem::Specification.new 'lux_assets' do |gem|
  gem.version     = File.read('./.version')
  gem.summary     = 'Web assets'
  gem.description = 'Web assets packer, convenience over configuration, simplified webpack or sprockets with cleaner configuration'
  gem.homepage    = 'https://github.com/dux/lux_assets'
  gem.license     = 'MIT'
  gem.author      = 'Dino Reic'
  gem.email       = 'rejotl@gmail.com'
  gem.files       = Dir['./**/*'].reject{ |it| File.directory?(it) } - ['./lux_assets.gemspec']

  gem.executables = ['lux_assets']

  gem.add_runtime_dependency 'colorize', '~> 0'
  gem.add_runtime_dependency 'awesome_print', '~> 1'

  gem.add_dependency 'thor', '~> 0'
end

