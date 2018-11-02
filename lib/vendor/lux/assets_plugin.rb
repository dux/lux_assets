module LuxAssets

  # include files from a plugin
  def plugin name
    # load pluigin if needed
    Lux.plugin name

    plugin = Lux.plugin.get name
    add '%s/**' % plugin[:folder]
  end

end

