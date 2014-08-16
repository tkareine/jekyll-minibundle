module Jekyll::Minibundle
  module AssetFileProperties
    def path
      asset_source_path
    end

    def relative_path
      path.sub(/\A#{@site.source}/, '')
    end

    def asset_destination_path
      File.join(asset_destination_dir, asset_destination_basename)
    end

    def destination(site_destination_dir)
      File.join(site_destination_dir, asset_destination_path)
    end

    def extname
      File.extname(relative_path)
    end

    def mtime
      File.stat(path).mtime.to_i
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
        'modified_time' => mtime.to_s,
        'extname'       => extname
      }
    end

    def write?
      true
    end
  end
end
