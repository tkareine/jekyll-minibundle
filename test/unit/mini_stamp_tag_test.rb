require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/mini_stamp_tag'

module Jekyll::Minibundle::Test
  class MiniStampTagTest < TestCase
    include FixtureConfig

    def test_raise_exception_if_argument_is_missing
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp %}')
      end
      assert_equal('Missing asset source and destination paths for ministamp tag; specify value such as "_assets/source.css assets/destination.css" as the argument', err.to_s)
    end

    def test_raise_exception_if_asset_destination_is_missing_in_string_argument_type
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp /_assets/site.css %}')
      end
      assert_equal('Missing asset destination path for ministamp tag; specify value such as "assets/destination.css" after asset source path argument, separated with a space', err.to_s)
    end

    def test_ignores_arguments_after_asset_destination_in_string_argument_type
      AssetFileRegistry.clear_all
      output = Liquid::Template
               .parse("{% ministamp #{STAMP_SOURCE_PATH} #{STAMP_DESTINATION_PATH} rest %}")
               .render({}, registers: {site: make_fake_site(site_fixture_path)})
      assert_equal(STAMP_DESTINATION_FINGERPRINT_PATH, output)
    end

    def test_raise_exception_if_invalid_arguments_syntax
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp source_path: src, destination_path: dst %}')
      end
      expected =
        'Failed parsing ministamp tag argument syntax as YAML: "source_path: src, destination_path: dst". ' \
        'Cause: (<unknown>): mapping values are not allowed in this context at line 1 column 35'
      assert_equal(expected, err.to_s)
    end

    def test_raise_exception_if_unsupported_argument_type
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse("{% ministamp ['source_path', 'src', 'destination_path', 'dst'] %}")
      end
      assert_equal("Unsupported ministamp tag argument type (Array), only String and Hash are supported: ['source_path', 'src', 'destination_path', 'dst']", err.to_s)
    end

    def test_raise_exception_if_asset_source_is_missing_in_hash_argument_type
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp {} %}')
      end
      assert_equal('Missing asset source path for ministamp tag; specify Hash entry such as "source_path: _assets/site.css"', err.to_s)
    end

    def test_raise_exception_if_asset_destination_is_missing_in_hash_argument_type
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% ministamp { source_path: src } %}')
      end
      assert_equal('Missing asset destination path for ministamp tag; specify Hash entry such as "destination_path: assets/site.css"', err.to_s)
    end
  end
end
