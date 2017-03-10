module Jekyll::Minibundle::Test
  module StaticFileConfig
    STATIC_FILE_PROPERTIES = [
      :defaults,
      :destination_rel_dir,
      :url,
      :name,
      :extname,
      :modified_time,
      :mtime,
      :path,
      :placeholders,
      :relative_path,
      :to_liquid,
      :type,
      :write?
    ].freeze
  end
end
