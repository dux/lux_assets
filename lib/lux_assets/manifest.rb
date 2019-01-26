# manifest file

module LuxAssets::Manifest
  INTEGRITY = 'sha512'
  MANIFEST  = Pathname.new(ENV.fetch('ASSETS_MANIFEST') { './public/manifest.json' })
  MANIFEST.write '{"files":{},"integrity":{}}' unless MANIFEST.exist?

  extend self

  def add name, path
    unless json['files'][name] == path
      json['files'][name]     = path
      write
    end

    !File.exist?('./public'+path)
  end

  def update_integrity
    for name, path in json['files']
      json['integrity'][name] = '%s-%s' % [INTEGRITY, `openssl dgst -#{INTEGRITY} -binary ./public#{path} | openssl base64 -A`.chomp]
    end

    write
  end

  private

  def json
    @json ||= JSON.load MANIFEST.read
  end

  def write
    MANIFEST.write JSON.pretty_generate(@json)
  end
end


