module Jekyll::Minibundle::Test
  module StaticFileConfig
    STATIC_FILE_PROPERTIES = [
      :basename,
      :data,
      :defaults,
      :destination_rel_dir,
      :extname,
      :modified_time,
      :mtime,
      :name,
      :path,
      :placeholders,
      :relative_path,
      :to_liquid,
      :type,
      :url,
      :write?
    ].freeze
  end
end
