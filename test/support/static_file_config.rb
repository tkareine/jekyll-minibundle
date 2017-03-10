module Jekyll::Minibundle::Test
  module StaticFileConfig
    STATIC_FILE_PROPERTIES = [
      :defaults,
      :destination_rel_dir,
      :url,
      :name,
      :basename,
      :extname,
      :modified_time,
      :mtime,
      :path,
      :placeholders,
      :relative_path,
      :to_liquid,
      :data,
      :type,
      :write?
    ].freeze
  end
end
