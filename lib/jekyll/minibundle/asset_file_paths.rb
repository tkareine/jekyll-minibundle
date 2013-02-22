module Jekyll::Minibundle
  module AssetFilePaths
    def path
      asset_source_path
    end

    def asset_destination_path
      File.join asset_destination_dir, asset_destination_basename
    end

    def destination(site_destination_dir)
      File.join site_destination_dir, asset_destination_path
    end

    def destination_exists?(site_destination_dir)
      File.exists? destination(site_destination_dir)
    end

    def mtime
      File.stat(path).mtime.to_i
    end

    def modified?
      last_mtime_of(path) != mtime
    end
  end
end
