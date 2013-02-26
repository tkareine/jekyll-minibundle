require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MiniBundleDevelopmentModeTest < TestCase
    include FixtureConfig

    EXPECTED_CSS_ASSET_PATHS = %w{reset common}.map { |f| File.join(CSS_BUNDLE_DESTINATION_PATH, "#{f}.css") }
    EXPECTED_JS_ASSET_PATHS = %w{dependency app}.map { |f| File.join(JS_BUNDLE_DESTINATION_PATH, "#{f}.js") }

    def test_css_assets_have_tags_in_configured_order
      with_precompiled_site :development do
        assert_equal EXPECTED_CSS_ASSET_PATHS, find_css_paths_from_index
      end
    end

    def test_js_assets_have_tags_in_configured_order
      with_precompiled_site :development do
        assert_equal EXPECTED_JS_ASSET_PATHS, find_js_paths_from_index
      end
    end

    def test_css_assets_are_copied_to_destination_dir
      with_precompiled_site :development do
        EXPECTED_CSS_ASSET_PATHS.each do |path|
          expect_file_exists_and_is_equal_to(destination_path(path), site_fixture_path(CSS_BUNDLE_SOURCE_DIR, File.basename(path)))
        end
      end
    end

    def test_js_assets_are_copied_to_destination_dir
      with_precompiled_site :development do
        EXPECTED_JS_ASSET_PATHS.each do |path|
          expect_file_exists_and_is_equal_to(destination_path(path), site_fixture_path(JS_BUNDLE_SOURCE_DIR, File.basename(path)))
        end
      end
    end

    def test_changing_css_asset_copies_it_to_destination_dir
      with_site do
        generate_site :development
        destination = destination_path CSS_BUNDLE_DESTINATION_PATH, 'common.css'
        source = source_path CSS_BUNDLE_SOURCE_DIR, 'common.css'
        ensure_file_mtime_changes { File.write source, 'h1 {}' }

        refute_equal File.read(destination), File.read(source)

        generate_site :development

        assert_equal File.read(destination), File.read(source)
      end
    end

    def test_changing_js_asset_copies_it_to_destination_dir
      with_site do
        generate_site :development
        destination = destination_path JS_BUNDLE_DESTINATION_PATH, 'app.js'
        source = source_path JS_BUNDLE_SOURCE_DIR, 'app.js'
        ensure_file_mtime_changes { File.write source, '(function() {})()' }

        refute_equal File.read(destination), File.read(source)

        generate_site :development

        assert_equal File.read(destination), File.read(source)
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site do
        expected_css_path = destination_path CSS_BUNDLE_DESTINATION_PATH, 'common.css'
        expected_js_path = destination_path JS_BUNDLE_DESTINATION_PATH, 'app.js'
        generate_site :development

        assert File.exists?(expected_css_path)
        assert File.exists?(expected_js_path)
        assert_equal 'assets/site/common.css', find_css_paths_from_index.last
        assert_equal 'assets/site/app.js', find_js_paths_from_index.last

        find_and_gsub_in_file source_path('index.html'), 'destination_path: assets/site', 'destination_path: /assets/site'
        generate_site :development

        assert File.exists?(expected_css_path)
        assert File.exists?(expected_js_path)
        assert_equal '/assets/site/common.css', find_css_paths_from_index.last
        assert_equal '/assets/site/app.js', find_js_paths_from_index.last
      end
    end

    def test_do_not_require_bundling_cmds
      with_site do
        with_env 'JEKYLL_MINIBUNDLE_CMD_CSS' => nil, 'JEKYLL_MINIBUNDLE_CMD_JS' => nil do
          generate_site :development
          pass
        end
      end
    end

    def test_do_not_copy_source_when_other_files_change
      with_site do
        generate_site :development
        expected_js_path = destination_path JS_BUNDLE_DESTINATION_PATH, 'app.js'
        org_mtime = mtime_of expected_js_path
        ensure_file_mtime_changes { File.write source_path(JS_BUNDLE_SOURCE_DIR, 'dependency.js'), '(function() {})()' }
        generate_site :development

        assert_equal org_mtime, mtime_of(expected_js_path)

        ensure_file_mtime_changes { FileUtils.touch 'index.html' }
        generate_site :development

        assert_equal org_mtime, mtime_of(expected_js_path)
      end
    end

    private

    def find_css_paths_from_index
      find_html_elements_from_index('head link[media="projection"]').map { |el| el['href'] }
    end

    def find_js_paths_from_index
      find_html_elements_from_index('body script').map { |el| el['src'] }
    end

    def find_html_elements_from_index(css)
      find_html_element(File.read(destination_path('index.html')), css)
    end

    def expect_file_exists_and_is_equal_to(actual, expected)
      assert File.exists?(actual)
      assert_equal File.read(expected), File.read(actual)
    end
  end
end
