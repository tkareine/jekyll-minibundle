module Jekyll::Minibundle::Test
  module StaticFileAPIConfig
    STATIC_FILE_API_PROPERTIES = [
      :defaults,
      :destination_rel_dir,
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
