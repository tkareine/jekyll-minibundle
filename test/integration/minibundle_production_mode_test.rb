require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MiniBundleProductionModeTest < TestCase
    include FixtureConfig

    def test_css_asset_bundle_has_configured_attributes
      with_precompiled_site :production do
        element = find_html_element_from_index %{head link[href="#{EXPECTED_CSS_BUNDLE_PATH}"]}
        assert_equal 'my-styles', element['id']
        assert_equal 'projection', element['media']
      end
    end

    def test_js_asset_bundle_has_configured_attributes
      with_precompiled_site :production do
        element = find_html_element_from_index %{body script[src="#{EXPECTED_JS_BUNDLE_PATH}"]}
        assert_equal 'my-scripts', element['id']
      end
    end

    def test_css_asset_bundle_has_stamp
      with_precompiled_site :production do
        assert_equal EXPECTED_CSS_BUNDLE_PATH, find_css_path_from_index
      end
    end

    def test_js_asset_bundle_has_stamp
      with_precompiled_site :production do
        assert_equal EXPECTED_JS_BUNDLE_PATH, find_js_path_from_index
      end
    end

    def test_css_asset_bundle_is_copied_to_destination_dir
      with_precompiled_site :production do
        assert File.exists?(destination_path(EXPECTED_CSS_BUNDLE_PATH))
      end
    end

    def test_js_asset_bundle_is_copied_to_destination_dir
      with_precompiled_site :production do
        assert File.exists?(destination_path(EXPECTED_JS_BUNDLE_PATH))
      end
    end

    def test_css_asset_bundle_is_concatenated_in_configured_order
      with_precompiled_site :production do
        bundle = File.read(destination_path(EXPECTED_CSS_BUNDLE_PATH))
        assert_operator bundle.index('html { margin: 0; }'), :<, bundle.index('p { margin: 0; }')
      end
    end

    def test_js_asset_bundle_is_concatenated_in_configured_order
      with_precompiled_site :production do
        bundle = File.read(destination_path(EXPECTED_JS_BUNDLE_PATH))
        assert_operator bundle.index('root.dependency = {};'), :<, bundle.index('root.app = {};')
      end
    end

    def test_js_asset_bundle_has_inserted_semicolons_between_assets
      with_precompiled_site :production do
        bundle = File.read(destination_path(EXPECTED_JS_BUNDLE_PATH))
        assert_match(%r|}\)\(window\)\n;\n\(function|, bundle)
      end
    end

    def test_css_asset_bundle_is_minified
      with_precompiled_site :production do
        source_contents_size = source_assets_size(CSS_BUNDLE_SOURCE_DIR, %w{reset common}, 'css')
        destination_contents_size = File.read(destination_path(EXPECTED_CSS_BUNDLE_PATH)).size
        assert_operator destination_contents_size, :<, source_contents_size
      end
    end

    def test_js_asset_bundle_is_minified
      with_precompiled_site :production do
        source_contents_size = source_assets_size(JS_BUNDLE_SOURCE_DIR, %w{dependency app}, 'js')
        destination_contents_size = File.read(destination_path(EXPECTED_JS_BUNDLE_PATH)).size
        assert_operator destination_contents_size, :<, source_contents_size
      end
    end

    def test_changing_css_assets_changes_bundle
      with_site do
        generate_site :production

        assert File.exists?(destination_path(EXPECTED_CSS_BUNDLE_PATH))

        ensure_file_mtime_changes { File.write source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css'), 'h1 {}' }
        generate_site :production, clear_cache: false

        refute File.exists?(destination_path(EXPECTED_CSS_BUNDLE_PATH))

        expected_new_path = 'assets/site-9fd3995d6f0fce425db81c3691dfe93f.css'

        assert_equal expected_new_path, find_css_path_from_index
        assert File.exists?(destination_path(expected_new_path))
      end
    end

    def test_changing_js_assets_changes_bundle
      with_site do
        generate_site :production

        assert File.exists?(destination_path(EXPECTED_JS_BUNDLE_PATH))

        ensure_file_mtime_changes { File.write source_path(JS_BUNDLE_SOURCE_DIR, 'app.js'), '(function() {})()' }
        generate_site :production, clear_cache: false

        refute File.exists?(destination_path(EXPECTED_JS_BUNDLE_PATH))

        expected_new_path = 'assets/site-375a0b430b0c5555d0edd2205d26c04d.js'

        assert_equal expected_new_path, find_js_path_from_index
        assert File.exists?(destination_path(expected_new_path))
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site do
        generate_site :production
        expected_css_path = destination_path EXPECTED_CSS_BUNDLE_PATH
        expected_js_path = destination_path EXPECTED_JS_BUNDLE_PATH

        assert File.exists?(expected_css_path)
        assert File.exists?(expected_js_path)
        assert_equal EXPECTED_CSS_BUNDLE_PATH, find_css_path_from_index
        assert_equal EXPECTED_JS_BUNDLE_PATH, find_js_path_from_index

        find_and_gsub_in_file source_path('index.html'), 'destination_path: assets/site', 'destination_path: /assets/site'
        generate_site :production

        assert File.exists?(expected_css_path)
        assert File.exists?(expected_js_path)
        assert_equal "/#{EXPECTED_CSS_BUNDLE_PATH}", find_css_path_from_index
        assert_equal "/#{EXPECTED_JS_BUNDLE_PATH}", find_js_path_from_index
      end
    end

    def test_bundles_assets_only_once_upon_startup
      with_site do
        with_env 'JEKYLL_MINIBUNDLE_CMD_JS' => cmd_to_remove_comments_and_count do
          generate_site :production
        end
        assert_equal 1, get_cmd_count
      end
    end

    def test_do_not_bundle_assets_when_nonsource_files_change
      with_site do
        with_env 'JEKYLL_MINIBUNDLE_CMD_JS' => cmd_to_remove_comments_and_count do
          generate_site :production
          expected_js_path = destination_path EXPECTED_JS_BUNDLE_PATH
          last_mtime = mtime_of expected_js_path

          assert_equal 1, get_cmd_count

          ensure_file_mtime_changes { File.write source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css'), 'h1 {}' }
          generate_site :production, clear_cache: false

          assert_equal last_mtime, mtime_of(expected_js_path)
          assert_equal 1, get_cmd_count

          ensure_file_mtime_changes { FileUtils.touch 'index.html' }
          generate_site :production, clear_cache: false

          assert_equal last_mtime, mtime_of(expected_js_path)
          assert_equal 1, get_cmd_count
        end
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
