require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/mini_stamp_tag'

module Jekyll::Minibundle::Test
  class MiniStampTagTest < TestCase
    include FixtureConfig

    def test_raise_exception_if_no_asset_source_argument
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp %}')
      end
      assert_equal "No asset source for ministamp tag; pass value such as '_assets/site.css' as the first argument", err.to_s
    end

    def test_raise_exception_if_no_asset_destination_argument
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp /_assets/site.css %}')
      end
      assert_equal "No asset destination for ministamp tag; pass value such as 'assets/site.css' as the second argument", err.to_s
    end

    def test_ignore_rest_arguments
      AssetFileRegistry.clear_all
      output = Liquid::Template
               .parse("{% ministamp #{STAMP_SOURCE_PATH} #{STAMP_DESTINATION_PATH} rest %}")
               .render({}, registers: {site: new_fake_site(site_fixture_path)})
      assert_equal STAMP_DESTINATION_FINGERPRINT_PATH, output
    end
  end
end
