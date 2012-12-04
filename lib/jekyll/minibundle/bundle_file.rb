module Jekyll::MiniBundle
  class BundleFile
    @@mtimes = Hash.new

    attr_reader :asset

    def initialize(bundle_config, contents)
      @site
      @basename = 
      @contents = site, contents
    end

    def destination(dest)
      bundle_dst_dir = bundle_config['dst_dir'] || 'assets' 
      basename = bundle_config['bundle_name'] || 'bundle'
      digest = Digest::MD5.hexdigest File.read(bundle_file)
      bundle_filename = "#{basename}-#{digest}.#{type}"
      File.join(dest, bundle_dst_dir, bundle_filename)
    end
    
    def destination(dest)
      File.join(dest, base)
    end

    def path
      @asset.pathname.to_s
    end

    def mtime
      @asset.mtime.to_i
    end

    def modified?
      @@mtimes[path] != mtime
    end

    def write dest
      dest_path = destination dest

      return false if File.exist?(dest_path) and !modified?
      @@mtimes[path] = mtime

      @asset.write_to dest_path
      true
    end
  end
end
