require 'tempfile'
require 'jekyll/minibundle/environment'

module Jekyll::Minibundle
  class AssetBundle
    def initialize(type, assets, site_dir)
      @type, @assets, @site_dir = type, assets, site_dir
      @temp_file = Tempfile.new("jekyll-minibundle-#{@type}-")
      at_exit { @temp_file.close! }
    end

    def path
      @temp_file.path
    end

    def make_bundle
      cmd = get_minifier_cmd
      exit_status = spawn_minifier(cmd) do |input|
        $stdout.puts  # place newline after "(Re)generating..." log messages
        log("Bundling #{@type} assets:")
        @assets.each do |asset|
          log(asset)
          IO.foreach(asset) { |line| input.write(line) }
          input.puts(';') if @type == :js
        end
      end
      fail "Bundling #{@type} assets failed with exit status #{exit_status}, command: #{cmd}" if exit_status != 0
      self
    end

    private

    if defined? ::Jekyll.logger  # introduced in Jekyll 1.0.0
      def log(msg)
        ::Jekyll.logger.info('Minibundle:', msg)
      end
    else
      def log(msg)
        $stdout.puts(msg)
      end
    end

    def get_minifier_cmd
      Environment.command_for(@type)
    end

    def spawn_minifier(cmd)
      pid = nil
      rd, wr = IO.pipe
      Dir.chdir(@site_dir) do
        pid = spawn(cmd, out: [@temp_file.path, 'w'], in: rd)
      end
      rd.close
      yield wr
      wr.close
      _, status = Process.waitpid2(pid)
      status.exitstatus
    ensure
      [rd, wr].each { |io| io.close unless io.closed? }
    end
  end
end
