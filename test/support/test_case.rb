require 'fileutils'
require 'ostruct'
require 'tempfile'
require 'minitest/autorun'
require 'nokogiri'
require 'support/assertions'
require 'jekyll'
require 'jekyll/minibundle'

module Jekyll::Minibundle::Test
  class TestCase < ::Minitest::Test
    include Assertions
    include ::Jekyll::Minibundle

    FIXTURE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../fixture'))

    def site_fixture_path(*args)
      File.join(FIXTURE_DIR, 'site', *args)
    end

    def source_path(*args)
      File.join(Dir.pwd, *args)
    end

    def destination_path(*args)
      File.join(Dir.pwd, '_site', *args)
    end

    def find_html_element(file, css)
      Nokogiri::HTML(file).css(css)
    end

    def find_and_gsub_in_file(file, pattern, replacement)
      old_content = File.read(file)
      new_content = old_content.gsub(pattern, replacement)
      File.write(file, new_content)
    end

    def merge_to_yaml_file(file, hash)
      IO.write(file, YAML.load_file(file).merge(hash).to_yaml)
    end

    def mtime_of(path)
      File.stat(path).mtime
    end

    def with_env(env)
      org_env = {}
      env.each do |k, v|
        org_env[k] = ENV[k]
        ENV[k] = v
      end
      yield
    ensure
      org_env.each { |k, v| ENV[k] = v }
    end

    def with_site_dir(&block)
      Dir.mktmpdir('jekyll-minibundle-test-site-') do |dir|
        Dir.chdir(dir) do
          _copy_fixture_site_dir(Dir.pwd)
          block.call(dir)
        end
      end
    end

    def new_fake_site(dir)
      OpenStruct.new(source: dir, static_files: [])
    end

    def new_real_site
      config = nil
      capture_io do
        config = Jekyll.configuration('source' => Dir.pwd, 'destination' => '_site')
      end
      Jekyll::Site.new(config)
    end

    def with_fake_site(&block)
      with_site_dir do |dir|
        block.call(new_fake_site(dir))
      end
    end

    def with_precompiled_site(mode, &block)
      Dir.chdir(_get_precompiled_site(mode), &block)
    end

    def generate_site(mode, options = {})
      env = {
        'JEKYLL_MINIBUNDLE_MODE'    => mode && mode.to_s,
        'JEKYLL_MINIBUNDLE_CMD_CSS' => options.fetch(:minifier_cmd_css, minifier_cmd_to_remove_comments),
        'JEKYLL_MINIBUNDLE_CMD_JS'  => options.fetch(:minifier_cmd_js, minifier_cmd_to_remove_comments)
      }
      with_env(env) { _generate_site(options) }
    end

    def ensure_file_mtime_changes(&block)
      sleep 1.5
      block.call
    end

    def minifier_cmd_to_remove_comments
      site_fixture_path('_bin/remove_comments')
    end

    def minifier_cmd_to_remove_comments_and_count(count_file = 'minifier_cmd_count')
      "#{site_fixture_path('_bin/with_count')} #{count_file} _bin/remove_comments"
    end

    def get_minifier_cmd_count(count_file = 'minifier_cmd_count')
      if File.exist?(count_file)
        File.read(count_file).to_i
      else
        0
      end
    end

    def get_send_results(obj, method_names)
      method_names.each_with_object({}) do |method_name, acc|
        acc[method_name] = obj.send(method_name)
      end
    end

    private

    def _copy_fixture_site_dir(dir)
      FileUtils.cp_r(site_fixture_path('.'), dir)
    end

    @@_precompiled_site_dirs = {}

    def _get_precompiled_site(mode)
      @@_precompiled_site_dirs[mode] ||= begin
        dir = Dir.mktmpdir("jekyll-minibundle-test-precompiled-site-#{mode}-")
        at_exit do
          FileUtils.rm_rf(dir)
          puts "\nCleaned precompiled site in #{mode} mode for tests: #{dir}"
        end
        Dir.chdir(dir) do
          _copy_fixture_site_dir(Dir.pwd)
          generate_site(mode)
        end
        dir
      end
    end

    def _generate_site(test_options)
      AssetFileRegistry.clear_all if test_options.fetch(:clear_cache, true)
      site = new_real_site
      capture_io { site.process }
    end
  end
end
