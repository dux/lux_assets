# manifest file

module LuxAssets::Manifest
  MANIFEST = Pathname.new('./public/manifest.json')

  extend self

  def add name, path
    json = JSON.load MANIFEST.read

    unless json['files'][name] == path
      json['files'][name] = path
      MANIFEST.write JSON.pretty_generate(json)
    end

    !File.exist?('./public'+path)
  end

  def get name
    json = JSON.load MANIFEST.read
    json['files'][name]
  end

  ###

  MANIFEST.write '{"files":{}}' unless MANIFEST.exist?
end


