require 'fileutils'
require 'ostruct'
require 'tempfile'
require 'minitest/autorun'
require 'nokogiri'
require 'jekyll'
require 'jekyll/minibundle'

module Jekyll::Minibundle::Test
  class TestCase < ::Minitest::Test
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
      Dir.mktmpdir("jekyll-minibundle-test-site-") do |dir|
        Dir.chdir(dir) do
          _copy_fixture_site_dir(Dir.pwd)
          yield dir
        end
      end
    end

    def new_fake_site(dir)
      OpenStruct.new(:source => dir)
    end

    def new_real_site
      config = nil
      capture_io do
        config = Jekyll.configuration(TestCase.site_generation_jekyll_options)
      end
      Jekyll::Site.new(config)
    end

    def with_fake_site(&block)
      with_site_dir do |dir|
        yield new_fake_site(dir)
      end
    end

    def with_precompiled_site(mode, &block)
      Dir.chdir(_get_precompiled_site(mode), &block)
    end

    def generate_site(mode, options = {})
      with_env('JEKYLL_MINIBUNDLE_MODE' => mode.to_s) do
        _generate_site(_get_site_generation_test_options(options))
      end
    end

    def ensure_file_mtime_changes(&block)
      sleep 1.5
      yield
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
      AssetFileRegistry.clear if test_options.fetch(:clear_cache)
      site = new_real_site
      capture_io { site.process }
    end

    def _get_site_generation_test_options(options)
      TestCase.site_generation_test_options.merge(options)
    end

    def self.site_generation_test_options
      { clear_cache: true }
    end

    def self.site_generation_jekyll_options
      {
        'source'      => Dir.pwd,
        'destination' => '_site'
      }
    end
  end
end
