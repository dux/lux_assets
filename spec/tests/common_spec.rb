require_relative '../spec_helper.rb'

describe LuxAssets do
  it 'has good number of files in a collection' do
    expect(LuxAssets.to_h.keys.length).to eq 2
    expect(LuxAssets.js(:single).files.length).to eq 3
    expect(LuxAssets.js(:group).files.length).to eq 3
  end

  it 'compiles Coffee' do
    data = LuxAssets.compile("./spec/assets/js/test.coffee")
    expect(data).to include('alert(123);')
  end

  it 'compiles TypecScript' do
    data = LuxAssets.compile("./spec/assets/js/test.ts")
    expect(data).to include('function greeter(person)')
  end

  it 'compiles Scss' do
    data = LuxAssets.compile("./spec/assets/css/test.scss")
    expect(data).to include('body p {')
  end

  it 'compiles assets' do
    LuxAssets.compile_all do |name, target|
      puts '    %s -> %s' % [name, target]
    end

    # auto prefixer test
    css = File.read Dir['./public/assets/*.css'][0]
    expect(css).to include('-webkit')

    expect(Dir.entries('./public/assets').length > 8).to be true
  end

  it 'deletes folders and files' do
    `rm -rf ./public/assets`
    Dir.rmdir('./public') if Dir.entries('./public').length == 2

    if LuxAssets::Manifest::MANIFEST.exist?
      LuxAssets::Manifest::MANIFEST.delete
    end
  end

  it 'expects openssl to be installed' do
    check = `openssl dgst -sha512 -binary ./LICENSE | openssl base64 -A`.chomp
    expect(check).to eq('N8B7a3flTwjxPfOcgyS0uLY9zYomxPv7PcimMZkKp73Q5RhlJ/yN5H/PBdtmmGu7qvcXLhqUDMZ6si5t38Qv7w==')
  end
end

