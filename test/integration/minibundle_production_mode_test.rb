require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MiniBundleProductionModeTest < TestCase
    include FixtureConfig

    def test_css_asset_bundle_has_stamp
      with_precompiled_site(:production) do
        assert_equal CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
      end
    end

    def test_js_asset_bundle_has_stamp
      with_precompiled_site(:production) do
        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index
      end
    end

    def test_css_asset_bundle_has_configured_attributes
      with_precompiled_site(:production) do
        element = find_css_element_from_index
        assert_equal 'my-styles', element['id']
        assert_equal 'projection', element['media']
      end
    end

    def test_js_asset_bundle_has_configured_attributes
      with_precompiled_site(:production) do
        element = find_js_element_from_index
        assert_equal 'my-scripts', element['id']
      end
    end

    def test_copies_css_asset_bundle_to_destination_dir
      with_precompiled_site(:production) do
        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_copies_js_asset_bundle_to_destination_dir
      with_precompiled_site(:production) do
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_concatenates_css_asset_bundle_in_configured_order
      with_precompiled_site(:production) do
        bundle = File.read(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_operator bundle.index('html { margin: 0; }'), :<, bundle.index('p { margin: 0; }')
      end
    end

    def test_concatenates_js_asset_bundle_in_configured_order
      with_precompiled_site(:production) do
        bundle = File.read(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_operator bundle.index('root.dependency = {};'), :<, bundle.index('root.app = {};')
      end
    end

    def test_inserts_semicolons_between_js_assets
      with_precompiled_site(:production) do
        bundle = File.read(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_match(%r|}\)\(window\)\n;\n\(function|, bundle)
      end
    end

    def test_minifies_css_asset_bundle
      with_precompiled_site(:production) do
        source_contents_size = source_assets_size(CSS_BUNDLE_SOURCE_DIR, %w{reset common}, 'css')
        destination_contents_size = File.read(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)).size
        assert_operator destination_contents_size, :<, source_contents_size
      end
    end

    def test_minifies_js_asset_bundle
      with_precompiled_site(:production) do
        source_contents_size = source_assets_size(JS_BUNDLE_SOURCE_DIR, %w{dependency app}, 'js')
        destination_contents_size = File.read(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)).size
        assert_operator destination_contents_size, :<, source_contents_size
      end
    end

    def test_changing_css_asset_source_rewrites_destination
      with_site_dir do
        generate_site(:production)
        org_mtime = mtime_of(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        ensure_file_mtime_changes { File.write(source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css'), 'h1 {}') }
        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = 'assets/site-9fd3995d6f0fce425db81c3691dfe93f.css'

        assert_equal new_destination, find_css_path_from_index
        assert File.exist?(destination_path(new_destination))
        assert_operator mtime_of(destination_path(new_destination)), :>, org_mtime
      end
    end

    def test_changing_js_asset_source_rewrites_destination
      with_site_dir do
        generate_site(:production)
        org_mtime = mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        ensure_file_mtime_changes { File.write(source_path(JS_BUNDLE_SOURCE_DIR, 'app.js'), '(function() {})()') }
        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = 'assets/site-375a0b430b0c5555d0edd2205d26c04d.js'

        assert_equal new_destination, find_js_path_from_index
        assert File.exist?(destination_path(new_destination))
        assert_operator mtime_of(destination_path(new_destination)), :>, org_mtime
      end
    end

    def test_touching_css_asset_source_rewrites_destination
      with_site_dir do
        generate_site(:production)
        destination = CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH
        org_mtime = mtime_of(destination_path(destination))
        ensure_file_mtime_changes { FileUtils.touch(source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css')) }
        generate_site(:production, clear_cache: false)

        assert_equal destination, find_css_path_from_index
        assert File.exist?(destination_path(destination))
        assert_operator mtime_of(destination_path(destination)), :>, org_mtime
      end
    end

    def test_touching_js_asset_source_rewrites_destination
      with_site_dir do
        generate_site(:production)
        destination = JS_BUNDLE_DESTINATION_FINGERPRINT_PATH
        org_mtime = mtime_of(destination_path(destination))
        ensure_file_mtime_changes { FileUtils.touch(source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')) }
        generate_site(:production, clear_cache: false)

        assert_equal destination, find_js_path_from_index
        assert File.exist?(destination_path(destination))
        assert_operator mtime_of(destination_path(destination)), :>, org_mtime
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site_dir do
        generate_site(:production)
        expected_css_path = destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)

        assert File.exist?(expected_css_path)
        assert File.exist?(expected_js_path)
        assert_equal CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index

        find_and_gsub_in_file(source_path('_layouts/default.html'), 'destination_path: assets/site', 'destination_path: /assets/site')
        generate_site(:production, clear_cache: false)

        assert File.exist?(expected_css_path)
        assert File.exist?(expected_js_path)
        assert_equal "/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index
        assert_equal "/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index
      end
    end

    def test_bundles_assets_only_once_at_startup
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)
        assert_equal 1, get_minifier_cmd_count
      end
    end

    def test_does_not_rebundle_assets_when_nonsource_files_change
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)
        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        last_mtime = mtime_of(expected_js_path)

        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes { File.write(source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css'), 'h1 {}') }
        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal last_mtime, mtime_of(expected_js_path)
        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes { FileUtils.touch('index.html') }
        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal last_mtime, mtime_of(expected_js_path)
        assert_equal 1, get_minifier_cmd_count
      end
    end

    def test_gets_minifier_command_from_site_configuration
      with_site_dir do
        merge_to_yaml_file('_config.yml', 'minibundle' => {'minifier_commands' => {'js' => minifier_cmd_to_remove_comments_and_count('minifier_cmd_config_count')}})

        generate_site(:production, minifier_cmd_js: nil)

        assert_equal 0, get_minifier_cmd_count
        assert_equal 1, get_minifier_cmd_count('minifier_cmd_config_count')
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_minifier_command_from_environment_overrides_command_from_site_configuration
      with_site_dir do
        merge_to_yaml_file('_config.yml', 'minibundle' => {'minifier_commands' => {'js' => minifier_cmd_to_remove_comments_and_count('minifier_cmd_config_count')}})

        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count('minifier_cmd_env_count'))

        assert_equal 0, get_minifier_cmd_count('minifier_cmd_config_count')
        assert_equal 1, get_minifier_cmd_count('minifier_cmd_env_count')
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_minifier_command_in_local_block_overrides_command_from_environment
      with_site_dir do
        IO.write('test.html', <<-END)
---
layout: override
title: Test
---
        END

        IO.write('_layouts/override.html', <<-END)
<!DOCTYPE html>
<html>
  <body>
    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: assets/deps
    assets:
      - dependency
    minifier_cmd: #{minifier_cmd_to_remove_comments_and_count('minifier_cmd_local_count')}
    {% endminibundle %}
  </body>
  <title>{{ page.title }}</title>
</html>
        END

        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count('minifier_cmd_global_count'))

        assert_equal 1, get_minifier_cmd_count('minifier_cmd_local_count')
        assert File.exist?(destination_path('assets/deps-71042d0b7c86c04e015fde694dd9f409.js'))

        assert_equal 1, get_minifier_cmd_count('minifier_cmd_global_count')
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    private

    def find_css_element_from_index
      find_html_element_from_index('head link[media!="screen"]')
    end

    def find_css_path_from_index
      find_css_element_from_index['href']
    end

    def find_js_element_from_index
      find_html_element_from_index('body script')
    end

    def find_js_path_from_index
      find_js_element_from_index['src']
    end

    def find_html_element_from_index(css)
      find_html_element(File.read(destination_path('index.html')), css).first
    end

    def source_assets_size(source_subdir, assets, type)
      assets.
        map { |f| File.read(site_fixture_path(source_subdir, "#{f}.#{type}")) }.
        join('').
        size
    end
  end
end
