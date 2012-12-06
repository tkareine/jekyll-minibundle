require 'tempfile'

module Jekyll::Minibundle
  class AssetBundle
    def initialize(type, assets)
      @type, @assets = type, assets
      @temp_file = Tempfile.new "jekyll-minibundle-#{@type}-"
      at_exit { @temp_file.unlink if @temp_file }
    end

    def path
      @temp_file.path
    end

    def make_bundle
      rd, wr = IO.pipe
      pid = spawn bundling_cmd, out: @temp_file.path, in: rd
      puts "Bundling #{@type} assets:"
      @assets.each do |asset|
        puts "  #{asset}"
        IO.foreach(asset) { |line| wr.write line }
      end
      Process.waitpid2 pid
      self
    ensure
      wr.close
    end

    private

    def bundling_cmd
      key = "JEKYLL_MINIBUNDLE_CMD_#{@type.upcase}"
      cmd = ENV[key]
      raise "You need to set bundling command in $#{key}" if !cmd
      cmd
    end
  end
end
