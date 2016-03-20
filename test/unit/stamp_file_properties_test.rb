require 'support/test_case'
require 'support/fixture_config'
require 'support/static_file_api_config'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class StampFilePropertiesTest < TestCase
    include FixtureConfig
    include StaticFileAPIConfig

    def setup
      @results ||= with_fake_site do |site|
        file = StampFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH)
        get_send_results(file, STATIC_FILE_API_PROPERTIES)
      end
    end

    def test_defaults
      assert_equal({}, @results.fetch(:defaults))
    end

    def test_destination_rel_dir
      assert_equal 'assets', @results.fetch(:destination_rel_dir)
    end

    def test_extname
      assert_equal '.css', @results.fetch(:extname)
    end

    def test_modified_time
      assert_instance_of Time, @results.fetch(:modified_time)
    end

    def test_mtime
      mtime = @results.fetch(:modified_time)
      assert_equal mtime.to_i, @results.fetch(:mtime)
    end

    def test_placeholders
      assert_equal({}, @results.fetch(:placeholders))
    end

    def test_relative_path
      assert_equal "/#{STAMP_SOURCE_PATH}", @results.fetch(:relative_path)
    end

    def test_to_liquid
      hash = @results.fetch(:to_liquid)
      assert_equal "/#{STAMP_SOURCE_PATH}", hash['path']
      assert_instance_of Time, hash['modified_time']
      assert_equal '.css', hash['extname']
    end

    def test_type
      assert_nil @results.fetch(:type)
    end

    def test_write?
      assert @results.fetch(:write?)
    end
  end
end
