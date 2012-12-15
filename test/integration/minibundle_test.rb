require 'support/test_case'

module Jekyll::Minibundle::Test
  class MiniBundleTest < TestCase
    EXPECTED_CSS_ASSET_PATH = 'assets/site-b2e0ecc1c100effc2c7353caad20c327.css'
    EXPECTED_JS_ASSET_PATH = 'assets/site-4782a1f67803038d4f8351051e67deb8.js'

    def test_css_asset_bundle_has_configured_attributes
      element = find_html_element_from_index(%{head link[href="#{EXPECTED_CSS_ASSET_PATH}"]}).first
      assert_equal 'my-styles', element['id']
      assert_equal 'projection', element['media']
    end

    def test_js_asset_bundle_has_configured_attributes
      element = find_html_element_from_index(%{body script[src="#{EXPECTED_JS_ASSET_PATH}"]}).first
      assert_equal 'my-scripts', element['id']
    end

    def test_css_asset_bundle_has_stamp
      actual = find_html_element_from_index('head link[media="projection"]').first['href']
      assert_equal EXPECTED_CSS_ASSET_PATH, actual
    end

    def test_js_asset_bundle_has_stamp
      actual = find_html_element_from_index('body script').first['src']
      assert_equal EXPECTED_JS_ASSET_PATH, actual
    end

    def test_css_asset_bundle_is_copied_to_destination_dir
      assert File.exists?(gensite_path(EXPECTED_CSS_ASSET_PATH))
    end

    def test_js_asset_bundle_is_copied_to_destination_dir
      assert File.exists?(gensite_path(EXPECTED_JS_ASSET_PATH))
    end

    def test_css_asset_bundle_is_concatenated_in_configured_order
      bundle = File.read(gensite_path(EXPECTED_CSS_ASSET_PATH))
      assert bundle.index('html { margin: 0; }') < bundle.index('p { margin: 0; }')
    end

    def test_js_asset_bundle_is_concatenated_in_configured_order
      bundle = File.read(gensite_path(EXPECTED_JS_ASSET_PATH))
      assert bundle.index('root.dependency = {};') < bundle.index('root.app = {};')
    end

    def test_js_asset_bundle_has_inserted_semicolons_between_assets
      bundle = File.read(gensite_path(EXPECTED_JS_ASSET_PATH))
      assert_match(%r|}\)\(window\)\n;\n\(function|, bundle)
    end

    def test_css_asset_bundle_is_minified
      source_contents_size = source_assets_size('_assets/styles', %w{reset common}, 'css')
      destination_contents_size = File.read(gensite_path(EXPECTED_CSS_ASSET_PATH)).size
      assert destination_contents_size < source_contents_size
    end

    def test_js_asset_bundle_is_minified
      source_contents_size = source_assets_size('_assets/scripts', %w{dependency app}, 'js')
      destination_contents_size = File.read(gensite_path(EXPECTED_JS_ASSET_PATH)).size
      assert destination_contents_size < source_contents_size
    end

    private

    def find_html_element_from_index(css)
      find_html_element(read_from_gensite('index.html'), css)
    end

    def source_assets_size(fixture_subdir, assets, type)
      assets.
        map { |f| File.read fixture_path(fixture_subdir, "#{f}.#{type}") }.
        join('').
        size
    end
  end
end
