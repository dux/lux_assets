relative_root './spec/assets'

asset :single do
  js do
    add 'js/test.js'
    add 'js/test.coffee'
    add 'js/test.ts'
  end

  css do
    add 'css/test.css'
    add 'css/test.scss'
  end
end

asset :group do
  js do
    add 'js/*'
  end

  css do
    add 'css/*'
  end
end