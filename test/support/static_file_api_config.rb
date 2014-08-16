module Jekyll::Minibundle::Test
  module StaticFileAPIConfig
    STATIC_FILE_API_PROPERTIES = [
      :to_liquid,
      :extname,
      :destination_rel_dir,
      :write?
    ]
  end
end
