module Jekyll::Minibundle
  module AssetFilePaths
    def path
      asset_source_path
    end

    def asset_path
      File.join asset_destination_dir, asset_destination_basename
    end

    def destination(site_destination_dir)
      File.join site_destination_dir, asset_destination_dir, asset_destination_basename
    end

    def mtime
      File.stat(path).mtime.to_i
    end

    def modified?
      last_mtime_of(path) != mtime
    end

    def destination_is_up_to_date?(site_destination_dir)
      File.exist?(destination(site_destination_dir)) && !modified?
    end
  end
end
