require 'support/test_case'
require 'nokogiri'

module Jekyll::Minibundle::Test
  class MiniBundleTest < TestCase
    EXPECTED_ASSET_PATH = 'assets/site-f78e0c4497343c33e9282df5d684540e.js'

    def test_asset_bundle_has_stamp
      actual = Nokogiri::HTML(read_from_gensite('index.html')).css('body script').first['src']
      assert_equal EXPECTED_ASSET_PATH, actual
    end

    def test_asset_bundle_is_copied_to_destination_dir
      assert File.exists?(gensite_path(EXPECTED_ASSET_PATH))
    end

    def test_asset_bundle_is_minified
      source_contents_size = %w{dependency app}.
        map { |f| File.read fixture_path("_assets/scripts/#{f}.js") }.
        join('').
        size
      destination_contents_size = File.read(gensite_path(EXPECTED_ASSET_PATH)).size
      assert destination_contents_size < source_contents_size
    end

    def test_asset_bundle_is_concatened_in_configured_order
      bundle = File.read(gensite_path(EXPECTED_ASSET_PATH))
      assert bundle.index('root.dependency = {};') < bundle.index('root.app = {};')
    end
  end
end
