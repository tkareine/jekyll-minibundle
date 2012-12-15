require 'fileutils'
require 'tempfile'
require 'minitest/autorun'
require 'nokogiri'
require 'jekyll'
require 'jekyll/minibundle'

module Jekyll::Minibundle::Test
  class TestCase < ::MiniTest::Unit::TestCase
    include ::Jekyll::Minibundle

    FIXTURE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../fixture/site'))

    def fixture_path(*args)
      File.join(FIXTURE_DIR, *args)
    end

    def gensite_path(*args)
      File.join(_gensite_dir, *args)
    end

    def read_from_gensite(*args)
      File.read gensite_path(*args)
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

    def _gensite_dir(&block)
      @@_gensite_dir ||= begin
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
        'source'      => fixture_path,
        'destination' => destination
      }
      capture_io { Jekyll::Site.new(Jekyll.configuration(options)).process }
    end
  end
end
