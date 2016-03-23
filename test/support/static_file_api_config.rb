module Jekyll::Minibundle::Test
  module StaticFileAPIConfig
    STATIC_FILE_API_PROPERTIES = [
      :defaults,
      :destination_rel_dir,
      :extname,
      :modified_time,
      :mtime,
      :placeholders,
      :relative_path,
      :to_liquid,
      :type,
      :write?
    ].freeze
  end
end
