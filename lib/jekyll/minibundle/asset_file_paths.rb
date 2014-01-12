module Jekyll::Minibundle
  module AssetFilePaths
    def path
      asset_source_path
    end

    def asset_destination_path
      File.join(asset_destination_dir, asset_destination_basename)
    end

    def destination(site_destination_dir)
      File.join(site_destination_dir, asset_destination_path)
    end

    def mtime
      File.stat(path).mtime.to_i
    end

    def modified?
      stamped_at != mtime
    end
  end
end
