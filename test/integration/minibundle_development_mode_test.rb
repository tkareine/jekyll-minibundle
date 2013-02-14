require 'support/test_case'

module Jekyll::Minibundle::Test
  class MiniBundleDevelopmentModeTest < TestCase
    CSS_DESTINATION_DIR = 'assets/site'
    CSS_SOURCE_DIR = '_assets/styles'

    JS_DESTINATION_DIR = 'assets/site'
    JS_SOURCE_DIR = '_assets/scripts'

    EXPECTED_CSS_ASSET_PATHS = %w{reset common}.map { |f| File.join(CSS_DESTINATION_DIR, "#{f}.css") }
    EXPECTED_JS_ASSET_PATHS = %w{dependency app}.map { |f| File.join(JS_DESTINATION_DIR, "#{f}.js") }

    def test_css_assets_have_link_tags_in_configured_order
      with_precompiled_site :development do
        paths = find_html_elements_from_index('head link[media="projection"]').map { |el| el['href'] }
        assert_equal EXPECTED_CSS_ASSET_PATHS, paths
      end
    end

    def test_js_assets_have_link_tags_in_configured_order
      with_precompiled_site :development do
        paths = find_html_elements_from_index('body script').map { |el| el['src'] }
        assert_equal EXPECTED_JS_ASSET_PATHS, paths
      end
    end

    def test_css_assets_are_copied_to_destination_dir
      with_precompiled_site :development do
        EXPECTED_CSS_ASSET_PATHS.each do |path|
          expect_file_exists_and_is_equal_to(destination_path(path), site_fixture_path(CSS_SOURCE_DIR, File.basename(path)))
        end
      end
    end

    def test_js_assets_are_copied_to_destination_dir
      with_precompiled_site :development do
        EXPECTED_JS_ASSET_PATHS.each do |path|
          expect_file_exists_and_is_equal_to(destination_path(path), site_fixture_path(JS_SOURCE_DIR, File.basename(path)))
        end
      end
    end

    def test_changing_css_asset_copies_it_to_destination_dir
      with_site do
        destination = destination_path CSS_DESTINATION_DIR, 'common.css'
        source = source_path CSS_SOURCE_DIR, 'common.css'

        generate_site :development
        ensure_file_mtime_change { File.write source, 'h1 {}' }
        refute_equal File.read(destination), File.read(source)
        generate_site :development
        assert_equal File.read(destination), File.read(source)
      end
    end

    def test_changing_js_asset_copies_it_to_destination_dir
      with_site do
        destination = destination_path JS_DESTINATION_DIR, 'app.js'
        source = source_path JS_SOURCE_DIR, 'app.js'

        generate_site :development
        ensure_file_mtime_change { File.write source, '(function() {})()' }
        refute_equal File.read(destination), File.read(source)
        generate_site :development
        assert_equal File.read(destination), File.read(source)
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

    private

    def find_html_elements_from_index(css)
      find_html_element(File.read(destination_path('index.html')), css)
    end

    def expect_file_exists_and_is_equal_to(actual, expected)
      assert File.exists?(actual)
      assert_equal File.read(expected), File.read(actual)
    end

    def ensure_file_mtime_change(&block)
      sleep 1.5  # ensures file mtime gets changed
      yield
    end
  end
end
