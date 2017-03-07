require 'tempfile'
require 'jekyll/minibundle/exceptions'
require 'jekyll/minibundle/files'
require 'jekyll/minibundle/log'

module Jekyll::Minibundle
  class AssetBundle
    TEMPFILE_PREFIX = 'jekyll-minibundle-'.freeze

    def initialize(config)
      @type = config.fetch(:type)
      @asset_paths = config.fetch(:asset_paths)
      @destination_path = config.fetch(:destination_path)
      @site_dir = config.fetch(:site_dir)
      @minifier_cmd = config.fetch(:minifier_cmd)

      unless @minifier_cmd
        raise <<-END
Missing minification command for bundling #{bundle_destination_path.inspect}. Specify it in
1) minibundle.minifier_commands.#{@type} setting in _config.yml,
2) $JEKYLL_MINIBUNDLE_CMD_#{@type.to_s.upcase} environment variable, or
3) minifier_cmd setting inside minibundle block.
        END
      end

      @tempfile = Tempfile.new([TEMPFILE_PREFIX, ".#{@type}"])
    end

    def close
      @tempfile.close!
      @tempfile = nil
    end

    def path
      raise IllegalStateError, 'Cannot get path of closed AssetBundle' unless @tempfile
      @tempfile.path
    end

    def make_bundle
      raise IllegalStateError, 'Cannot make bundle with closed AssetBundle' unless @tempfile
      exit_status = spawn_minifier(@minifier_cmd) do |input|
        $stdout.puts  # place newline after "(Re)generating..." log messages
        Log.info("Bundling #{bundle_destination_path}:")
        @asset_paths.each do |asset|
          Log.info(' ' + relative_path_from(asset, @site_dir))
          IO.foreach(asset) { |line| input.write(line) }
          input.puts(';') if @type == :js
        end
      end
      if exit_status != 0
        msg = "Bundling #{bundle_destination_path.inspect} failed with exit status #{exit_status}, command: #{@minifier_cmd.inspect}"
        log_minifier_error(msg)
        raise msg
      end
      self
    end

    private

    def relative_path_from(path, base)
      path.sub(%r{\A#{base}/}, '')
    end

    def spawn_minifier(cmd)
      pid = nil
      rd, wr = IO.pipe
      Dir.chdir(@site_dir) do
        pid = spawn(cmd, out: [@tempfile.path, 'w'], in: rd)
      end
      rd.close
      yield wr
      wr.close
      _, status = Process.waitpid2(pid)
      status.exitstatus
    rescue => e
      raise "Bundling #{bundle_destination_path.inspect} failed: #{e}"
    ensure
      [rd, wr].each { |io| io.close unless io.closed? }
    end

    def log_minifier_error(message)
      last_bytes = Files.read_last(@tempfile.path, 2000)

      return if last_bytes.empty?

      Log.error("#{message}, last #{last_bytes.size} bytes of minifier output:")

      last_bytes
        .gsub(/[^[:print:]\t\n]/) { |ch| '\x' + ch.unpack('H2').first }
        .split("\n")
        .each { |line| Log.error(line) }
    end

    def bundle_destination_path
      "#{@destination_path}.#{@type}"
    end
  end
end
