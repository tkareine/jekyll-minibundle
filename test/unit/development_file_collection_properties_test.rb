require 'support/test_case'
require 'support/fixture_config'
require 'support/static_file_api_config'
require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle::Test
  class DevelopmentFileCollectionPropertiesTest < TestCase
    include FixtureConfig
    include StaticFileAPIConfig

    def setup
      @results ||= with_fake_site do |site|
        files = DevelopmentFileCollection.new(site, bundle_config).instance_variable_get('@files')
        {
          dependency: get_send_results(files[0], STATIC_FILE_API_PROPERTIES),
          app: get_send_results(files[1], STATIC_FILE_API_PROPERTIES)
        }
      end
    end

    def test_to_liquid
      hash = @results.fetch(:dependency).fetch(:to_liquid)
      assert_equal "/#{JS_BUNDLE_SOURCE_DIR}/dependency.js", hash['path']
      refute_empty hash['modified_time']
      assert_equal '.js', hash['extname']

      hash = @results.fetch(:app).fetch(:to_liquid)
      assert_equal "/#{JS_BUNDLE_SOURCE_DIR}/app.js", hash['path']
      refute_empty hash['modified_time']
      assert_equal '.js', hash['extname']
    end

    private

    def bundle_config
      {
       'type'             => :js,
       'source_dir'       => JS_BUNDLE_SOURCE_DIR,
       'assets'           => %w{dependency app},
       'destination_path' => JS_BUNDLE_DESTINATION_PATH,
       'attributes'       => {}
      }
    end
  end
end
