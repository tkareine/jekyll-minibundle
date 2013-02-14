require 'support/test_case'

module Jekyll::Minibundle::Test
  class MiniBundleProductionModeTest < TestCase
    EXPECTED_CSS_ASSET_PATH = 'assets/site-b2e0ecc1c100effc2c7353caad20c327.css'
    EXPECTED_JS_ASSET_PATH = 'assets/site-4782a1f67803038d4f8351051e67deb8.js'

    def test_css_asset_bundle_has_configured_attributes
      with_precompiled_site :production do
        element = find_html_element_from_index %{head link[href="#{EXPECTED_CSS_ASSET_PATH}"]}
        assert_equal 'my-styles', element['id']
        assert_equal 'projection', element['media']
      end
    end

    def test_js_asset_bundle_has_configured_attributes
      with_precompiled_site :production do
        element = find_html_element_from_index %{body script[src="#{EXPECTED_JS_ASSET_PATH}"]}
        assert_equal 'my-scripts', element['id']
      end
    end

    def test_css_asset_bundle_has_stamp
      with_precompiled_site :production do
        assert_equal EXPECTED_CSS_ASSET_PATH, find_css_path_from_index
      end
    end

    def test_js_asset_bundle_has_stamp
      with_precompiled_site :production do
        assert_equal EXPECTED_JS_ASSET_PATH, find_js_path_from_index
      end
    end

    def test_css_asset_bundle_is_copied_to_destination_dir
      with_precompiled_site :production do
        assert File.exists?(destination_path(EXPECTED_CSS_ASSET_PATH))
      end
    end

    def test_js_asset_bundle_is_copied_to_destination_dir
      with_precompiled_site :production do
        assert File.exists?(destination_path(EXPECTED_JS_ASSET_PATH))
      end
    end

    def test_css_asset_bundle_is_concatenated_in_configured_order
      with_precompiled_site :production do
        bundle = File.read(destination_path(EXPECTED_CSS_ASSET_PATH))
        assert bundle.index('html { margin: 0; }') < bundle.index('p { margin: 0; }')
      end
    end

    def test_js_asset_bundle_is_concatenated_in_configured_order
      with_precompiled_site :production do
        bundle = File.read(destination_path(EXPECTED_JS_ASSET_PATH))
        assert bundle.index('root.dependency = {};') < bundle.index('root.app = {};')
      end
    end

    def test_js_asset_bundle_has_inserted_semicolons_between_assets
      with_precompiled_site :production do
        bundle = File.read(destination_path(EXPECTED_JS_ASSET_PATH))
        assert_match(%r|}\)\(window\)\n;\n\(function|, bundle)
      end
    end

    def test_css_asset_bundle_is_minified
      with_precompiled_site :production do
        source_contents_size = source_assets_size('_assets/styles', %w{reset common}, 'css')
        destination_contents_size = File.read(destination_path(EXPECTED_CSS_ASSET_PATH)).size
        assert destination_contents_size < source_contents_size
      end
    end

    def test_js_asset_bundle_is_minified
      with_precompiled_site :production do
        source_contents_size = source_assets_size('_assets/scripts', %w{dependency app}, 'js')
        destination_contents_size = File.read(destination_path(EXPECTED_JS_ASSET_PATH)).size
        assert destination_contents_size < source_contents_size
      end
    end

    def test_changing_css_assets_changes_bundle
      with_site do
        generate_site :production
        assert File.exists?(destination_path(EXPECTED_CSS_ASSET_PATH))
        File.write source_path('_assets/styles/common.css'), 'h1 {}'
        generate_site :production
        refute File.exists?(destination_path(EXPECTED_CSS_ASSET_PATH))
        expected_new_path = 'assets/site-9fd3995d6f0fce425db81c3691dfe93f.css'
        assert_equal expected_new_path, find_css_path_from_index
        assert File.exists?(destination_path(expected_new_path))
      end
    end

    def test_changing_js_assets_changes_bundle
      with_site do
        generate_site :production
        assert File.exists?(destination_path(EXPECTED_JS_ASSET_PATH))
        File.write source_path('_assets/scripts/app.js'), '(function() {})()'
        generate_site :production
        refute File.exists?(destination_path(EXPECTED_JS_ASSET_PATH))
        expected_new_path = 'assets/site-375a0b430b0c5555d0edd2205d26c04d.js'
        assert_equal expected_new_path, find_js_path_from_index
        assert File.exists?(destination_path(expected_new_path))
      end
    end

    private

    def find_css_path_from_index
      find_html_element_from_index('head link[media="projection"]')['href']
    end

    def find_js_path_from_index
      find_html_element_from_index('body script')['src']
    end

    def find_html_element_from_index(css)
      find_html_element(File.read(destination_path('index.html')), css).first
    end

    def source_assets_size(source_subdir, assets, type)
      assets.
        map { |f| File.read site_fixture_path(source_subdir, "#{f}.#{type}") }.
        join('').
        size
    end
  end
end
