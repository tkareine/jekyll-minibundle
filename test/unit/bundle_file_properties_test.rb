require 'support/test_case'
require 'support/fixture_config'
require 'support/static_file_api_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFilePropertiesTest < TestCase
    include FixtureConfig
    include StaticFileAPIConfig

    def setup
      @results ||= with_fake_site do |site|
        file = BundleFile.new(site, bundle_config(minifier_cmd_to_remove_comments))
        get_send_results(file, STATIC_FILE_API_PROPERTIES)
      end
    end

    def test_to_liquid
      hash = @results.fetch(:to_liquid)
      assert_match(%r{/jekyll-minibundle-.+\.js\z}, hash['path'])
      refute_empty hash['modified_time']
      assert_equal '.js', hash['extname']
    end

    private

    def bundle_config(minifier_cmd)
      {
        'type'             => :js,
        'source_dir'       => JS_BUNDLE_SOURCE_DIR,
        'assets'           => %w{dependency app},
        'destination_path' => JS_BUNDLE_DESTINATION_PATH,
        'attributes'       => {},
        'minifier_cmd'     => minifier_cmd
      }
    end
  end
end
