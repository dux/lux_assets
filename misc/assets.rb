# relative_root './app/assets' # default root for relative assets

asset :admin do
  js do
    # add 'js/admin/js_vendor/*'
    # add '/Used/foo/app/bar/asssets/admin.js'
    # add ['list', 'of', 'files']
    # add proc { 'js string' }
  end

  css do
    # add 'css/admin/index.scss'
    # add proc { 'css string' }
  end
end

asset :main do
  js do

  end

  css do

  end
end
