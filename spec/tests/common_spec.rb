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
    `rm -rf ./public/assets`
    Dir.rmdir('./public') if Dir.entries('./public').length == 2
  end
end

