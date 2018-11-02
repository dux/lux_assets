# Web assets

Lightweight web assets packer that loves simplicity.

* framework agnostic, use anywhere
* compiles js, coffee, typescript, css, sass "out of the box"
* keeps manifest in a single file
* plugable to handle any other extension
* update manifest file for production
* autoprefixer, minify, gzip the output
* add rake tasks

## Instalation

Add `lux_assets` gem to `Gemfile` and then `bundle install`
```
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
  lux_assets show            # Show all files/data in manifest
```

1. Start with `lux_assets install`
2. Modify ./config/assets.rb
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

```
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


## Extending

### Adding processor for new file type

This is all that is needed to add support for TypeScript compilation.

```
class LuxAssets::Element
  def compile_ts
    LuxAssets.run "node_modules/typescript/.bin/tsc --outFile '#{@cache}' '#{@source}'"
  end
end
```

### Added new plugin for file adder

You need to extend `LuxAssets` class and call method `add` with list of files or a proc.

```
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

