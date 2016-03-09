require 'tempfile'
require 'jekyll/minibundle/compatibility'

module Jekyll::Minibundle
  class AssetBundle
    def initialize(config)
      @type = config.fetch(:type)
      @asset_paths = config.fetch(:asset_paths)
      @site_dir = config.fetch(:site_dir)
      @minifier_cmd = config.fetch(:minifier_cmd)

      unless @minifier_cmd
        fail <<-END
Missing minification command for bundling #{@type} assets. Specify it in
1) minibundle.minifier_commands.#{@type} setting in _config.yml,
2) $JEKYLL_MINIBUNDLE_CMD_#{@type.to_s.upcase} environment variable, or
3) minifier_cmd setting inside minibundle block.
        END
      end

      @temp_file = Tempfile.new(["jekyll-minibundle-", ".#{@type}"])
      at_exit { @temp_file.close! }
    end

    def path
      @temp_file.path
    end

    def make_bundle
      exit_status = spawn_minifier(@minifier_cmd) do |input|
        $stdout.puts  # place newline after "(Re)generating..." log messages
        Compatibility.log_info("Bundling #{@type} assets:")
        @asset_paths.each do |asset|
          Compatibility.log_info(relative_path_from(asset, @site_dir))
          IO.foreach(asset) { |line| input.write(line) }
          input.puts(';') if @type == :js
        end
      end
      if exit_status != 0
        output = File.read(@temp_file.path)
        chars_of_output = 5000
        truncated_output = output[-chars_of_output..-1] || output
        fail "Bundling #{@type} assets failed with exit status #{exit_status}, command: #{@minifier_cmd} Last #{chars_of_output} chars of output: #{truncated_output}"
      end
      self
    end

    private

    def relative_path_from(path, base)
      path.sub(/\A#{base}\//, '')
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
