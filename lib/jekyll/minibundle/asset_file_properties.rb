module Jekyll::Minibundle
  module AssetFileProperties
    def asset_destination_path
      File.join(asset_destination_dir, asset_destination_basename)
    end

    # Conformance to remaining Jekyll StaticFile public API methods

    def path
      asset_source_path
    end

    def relative_path
      path.sub(/\A#{@site.source}/, '')
    end

    def destination(site_destination_dir)
      File.join(site_destination_dir, asset_destination_path)
    end

    def url
      asset_destination_path
    end

    def modified_time
      File.stat(path).mtime
    end

    def mtime
      modified_time.to_i
    end

    def modified?
      stamped_at != mtime
    end

    def destination_rel_dir
      asset_destination_dir
    end

    def to_liquid
      {
        'path'          => relative_path,
        'modified_time' => modified_time,
        'extname'       => extname
      }
    end

    def write?
      true
    end

    def type
      nil  # no collection present
    end

    def defaults
      {}
    end

    def placeholders
      {}
    end
  end
end
