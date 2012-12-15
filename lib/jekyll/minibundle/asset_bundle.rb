require 'tempfile'

module Jekyll::Minibundle
  class AssetBundle
    def initialize(type, assets, site_dir)
      @type, @assets, @site_dir = type, assets, site_dir
      @temp_file = Tempfile.new "jekyll-minibundle-#{@type}-"
      at_exit { @temp_file.close! }
    end

    def path
      @temp_file.path
    end

    def make_bundle
      pipe_bundling_to_temp_file bundling_cmd do |wr|
        puts "Bundling #{@type} assets:"
        @assets.each do |asset|
          puts "  #{asset}"
          IO.foreach(asset) { |line| wr.write line }
          wr.puts ';' if @type == :js
        end
      end
      self
    end

    private

    def bundling_cmd
      key = "JEKYLL_MINIBUNDLE_CMD_#{@type.upcase}"
      cmd = ENV[key]
      raise "You need to set bundling command in $#{key}" if !cmd
      cmd
    end

    def pipe_bundling_to_temp_file(cmd)
      pid = nil
      rd, wr = IO.pipe
      Dir.chdir @site_dir do
        pid = spawn cmd, out: [@temp_file.path, 'w'], in: rd
      end
      yield wr
      wr.close
      Process.waitpid2 pid
    ensure
      wr.close unless wr.closed?
    end
  end
end
