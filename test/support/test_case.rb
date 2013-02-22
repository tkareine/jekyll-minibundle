require 'fileutils'
require 'tempfile'
require 'minitest/autorun'
require 'nokogiri'
require 'jekyll'
require 'jekyll/minibundle'

module Jekyll::Minibundle::Test
  class TestCase < ::MiniTest::Unit::TestCase
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
      old_content = File.read file
      new_content = old_content.gsub pattern, replacement
      File.write file, new_content
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

    def with_site(&block)
      Dir.mktmpdir "jekyll-minibundle-test-site-" do |dir|
        Dir.chdir dir do
          _copy_fixture_site_dir Dir.pwd
          yield dir
        end
      end
    end

    def with_precompiled_site(mode, &block)
      Dir.chdir(_get_precompiled_site(mode), &block)
    end

    def generate_site(mode)
      with_env 'JEKYLL_MINIBUNDLE_MODE' => mode.to_s do
        _generate_site Dir.pwd, '_site'
      end
    end

    def ensure_file_mtime_changes(&block)
      sleep 1.5
      yield
    end

    private

    def _copy_fixture_site_dir(dir)
      FileUtils.cp_r site_fixture_path('.'), dir
    end

    @@_precompiled_site_dirs = {}

    def _get_precompiled_site(mode)
      @@_precompiled_site_dirs[mode] ||= begin
        dir = Dir.mktmpdir("jekyll-minibundle-test-precompiled-site-#{mode}-")
        at_exit do
          FileUtils.rm_rf dir
          puts "\nCleaned precompiled site for tests: #{dir}"
        end
        Dir.chdir(dir) do
          _copy_fixture_site_dir Dir.pwd
          generate_site mode
        end
        puts "\nGenerated precompiled site in #{mode} mode for tests: #{dir}"
        dir
      end
    end

    def _generate_site(source, destination)
      options = {
        'source'      => source,
        'destination' => destination
      }
      capture_io { Jekyll::Site.new(Jekyll.configuration(options)).process }
    end
  end
end
