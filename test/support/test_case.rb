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
    SOURCE_DIR = File.join(FIXTURE_DIR, 'site')

    def source_path(*args)
      File.join(SOURCE_DIR, *args)
    end

    def destination_path(*args)
      File.join(_destination_dir, *args)
    end

    def read_from_destination(*args)
      File.read destination_path(*args)
    end

    def find_html_element(file, css)
      Nokogiri::HTML(file).css(css)
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

    private

    def _destination_dir(&block)
      @@_destination_dir ||= begin
        dir = Dir.mktmpdir('jekyll-minibundle-test-')
        at_exit do
          FileUtils.rm_rf dir
          puts "\nCleaned generated site for tests: #{dir}"
        end
        Dir.chdir(dir) { _generate_site dir }
        puts "\nGenerated site for tests: #{dir}"
        dir
      end
    end

    def _generate_site(destination)
      options = {
        'source'      => source_path,
        'destination' => destination
      }
      capture_io { Jekyll::Site.new(Jekyll.configuration(options)).process }
    end
  end
end
