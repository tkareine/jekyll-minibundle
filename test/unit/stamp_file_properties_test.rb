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
        file = StampFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH, &stamp_basenamer)
        get_send_results(file, STATIC_FILE_API_PROPERTIES)
      end
    end

    def test_to_liquid
      hash = @results.fetch(:to_liquid)
      assert_equal "/#{STAMP_SOURCE_PATH}", hash['path']
      refute_empty hash['modified_time']
      assert_equal '.css', hash['extname']
    end

    private

    def stamp_basenamer
      ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
    end
  end
end
