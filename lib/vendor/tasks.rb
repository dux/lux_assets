require 'colorize'

$lux_assets_bin ||= proc do |command|
  bin     = Pathname.new(__dir__).join('../../bin/lux_assets').to_s
  system '%s %s' % [bin, command]
end

namespace :assets do
  desc 'Clear all assets'
  task :clear do
    $lux_assets_bin.call :clear
  end

  desc 'Install all needed packages via yarn'
  task :install do
    $lux_assets_bin.call :install
  end

  desc 'Compile assets to public/assets and generate mainifest.json'
  task compile: :env do
    LuxAssets.compile_all do |name, path|
      puts "Compile #{name.green} -> #{path}"
    end
  end

  desc 'Show all files/data in manifest'
  task show: :env do
    ap LuxAssets.to_h
  end

  desc 'Upload assets to S3'
  task :s3_upload do
    puts 'aws s3 sync ./public s3://bucket.location --cache-control "max-age=31536000, public"'
  end
end

