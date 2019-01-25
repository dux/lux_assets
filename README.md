# Lux web assets

Lightweight web assets packer that loves simplicity.

[![asciicast](https://asciinema.org/a/IanaNAq9CDKvUg7dweqxzhoAV.svg)](https://asciinema.org/a/IanaNAq9CDKvUg7dweqxzhoAV)

* framework agnostic, use anywhere
* compiles js, coffee, typescript, css, sass "out of the box"
* keeps manifest in a single file
* plugable to handle any other extension
* update manifest file for production
* autoprefixer, minify, gzip the output
* adds rake tasks

Assets pipeline

* get list of files or data
* individually compile every asset, join the result in a single file
* css specific
  * scan css source and put sh1 data stamp to files found in ./public dir
  * autoprefixer
* js specific
  * babel
* minify
* sha1 prefix, gzip, add to manifest


## Instalation

Add `lux_assets` gem to `Gemfile` and then `bundle install`
```ruby
gem 'lux_assets'
```

## Using

To use the gem we have bin file in a path (build with Thor gem) named `lux_assets`.

```
~/dev/app $ lux_assets
Commands:
  lux_assets clear           # Clear all caches
  lux_assets compile         # Compile assets for production
  lux_assets help [COMMAND]  # Describe available commands or one specific command
  lux_assets install         # Install all needed packages via yarn
  lux_assets monitor         # Montitor and compile changed files
  lux_assets show            # Show all files/data in manifest
```

1. Start with `lux_assets install`
2. Modify `./config/assets.rb`
3. Compile with `lux_assets compile`
4. Inspect added files with `lux_assets show`

### To compile

```
~/dev/app $ lux_assets compile
~/dev/app $ rake assets:compile
Compile js/admin -> /assets/js-admin-d1b55490e6327ba81e60b24539c6086ee1fe5d48.js
Compile js/main -> /assets/js-main-a72368758567e466aa01643b1e7426120dbca65b.js
Compile css/admin -> /assets/css-admin-f486d0d464932a9da584289007d170695dce23ce.css
Compile css/main -> /assets/css-main-1b6d66a32ad6af5fd34edbe4369585be351790cd.css
```

### To get list of all added files

`lux_assets show`

or

```
require 'lux_assets'

ap LuxAssets.to_h
```


## Example ./config/assets.rb

```ruby
# relative_root './app/assets'

asset :admin do
  js do
    add 'js/admin/js_vendor/*' # will add all files from a folder
    add 'js/shared/**'         # will add all files from a folder + subfolders
    add '/Used/foo/app/bar/asssets/admin.js'
    add ['list', 'of', 'files']
    add proc { 'js string' }
    plugin :foo
  end

  css do
    add 'css/admin/index.scss'
    add proc { 'css string' }
  end
end

asset :main do
  js do
    # ...
  end

  css do
    # ...
  end
end
```

### What can you add

* relative file
* absolute file
* list of files
* proc

If you add proc, proc retun must be a string, not a file

## API usage - all you need to know

### In your code

```ruby
require 'lux_assets'

# Get list of files defined in config
LuxAssets.to_s[:js]
LuxAssets.files(:js, :main)
LuxAssets.files('js/main')
LuxAssets.js(:main).files

# compile single asset with debug info for dev
LuxAssets.compile('js/main/index.coffee')
LuxAssets.compile('css/main/index.scss')

# compile file group for production
LuxAssets.js(:main).compile
LuxAssets.css(:main).compile
LuxAssets.css(:main).compile

# compile all assets for production
LuxAssets.compile_all do |name, path|
  puts "Compile #{name.green} -> #{path}"
end
```

### In config/assets.rb

```ruby
# root for relative files
relative_root './app/assets'

asset :admin do
  js do
    add 'js/admin/js_vendor/*'
    add 'js/admin/js/*'
    add 'js/shared/*'
    add 'js/admin/index.coffee'
  end

  css do
    add 'css/admin/index.scss'
  end
end
```

## Extending

### Adding processor for new file type

This is all that is needed to add support for TypeScript compilation.

```
yarn add typescript
```

```ruby
class LuxAssets::Element
  def compile_ts
    system "node_modules/typescript/.bin/tsc --outFile '#{@cache}' '#{@source}'"
  end
end
```

### Added new plugin for file adder

You need to extend `LuxAssets` class and call method `add` with list of files or a proc.

```ruby
module LuxAssets
  # include files from a plugin
  def plugin name
    plugin = Lux.plugin.get name
    add '%s/**' % plugin[:folder]
  end
end
```

## Rakefile

If you want to use `Rake` tasks and not `lux_assets` bin, there is a wrapper.

In `Rakefile` just add `require 'lux_assets'` and tasks will automaticly be added to your list of tasks.

Rake taks will call :env task to set up environment.

```ruby
# Rakefile

require 'lux_assets'

task :env do
  # require './config/application'
end

task :default do
  puts 'rake -T to get all tasks'
end
```

To test, `rake -T`

## Documentation

Rdoc from rubydoc.info - https://www.rubydoc.info/gems/lux_assets

## Contact

The best way to get in touch is to email reic.dino@gmail.com.

## Security

Assets are packed locally, no known security issues.

## Licence

MIT licence https://github.com/dux/lux_assets/blob/master/LICENSE
