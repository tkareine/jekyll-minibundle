require 'fileutils'
require 'tempfile'
require 'minitest/autorun'
require 'jekyll'
require 'jekyll/minibundle'

module Jekyll::Minibundle::Test
  class TestCase < ::MiniTest::Unit::TestCase
    FIXTURE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../fixture/site'))

    def fixture_path(*args)
      File.join(FIXTURE_DIR, *args)
    end

    def gensite_path(*args)
      File.join(_gensite_dir, *args)
    end

    private

    def _gensite_dir(&block)
      @@_gensite_dir ||= begin
        dir = Dir.mktmpdir
        at_exit do
          FileUtils.rm_rf dir
          puts "Cleaned generated site for tests: #{dir}"
        end
        Dir.chdir(dir) { _generate_site dir }
        puts "Generated site for tests: #{dir}"
        dir
      end
    end

    def _generate_site(destination)
      options = {
        'source'      => fixture_path,
        'destination' => destination
      }
      Jekyll::Site.new(Jekyll.configuration(options)).process
    end
  end
end
