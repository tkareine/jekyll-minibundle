require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MinibundleProductionModeTest < TestCase
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
        assert_equal '', element['async']
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
        assert_match(/}\)\(window\)\n;\n\(function/, bundle)
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

    def test_changing_asset_source_file_rewrites_destination
      with_site_dir do
        generate_site(:production)

        ensure_file_mtime_changes { File.write(source_path(JS_BUNDLE_SOURCE_DIR, 'app.js'), '(function() {})()') }

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = 'assets/site-375a0b430b0c5555d0edd2205d26c04d.js'

        assert_equal new_destination, find_js_path_from_index
        assert File.exist?(destination_path(new_destination))
      end
    end

    def test_touching_asset_source_file_rewrites_destination
      with_site_dir do
        generate_site(:production)

        org_mtime = mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        ensure_file_mtime_changes { FileUtils.touch(source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')) }

        generate_site(:production, clear_cache: false)

        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_operator mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)), :>, org_mtime
      end
    end

    def test_changing_asset_source_directory_rewrites_destination
      with_site_dir do
        generate_site(:production)

        org_mtime = mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        match_snippet = <<-END
    {% minibundle js %}
    source_dir: _assets/scripts
        END

        replacement_snippet = <<-END
    {% minibundle js %}
    source_dir: _assets/scripts2
        END

        ensure_file_mtime_changes do
          FileUtils.mv(source_path('_assets/scripts'), source_path('_assets/scripts2'))
          find_and_gsub_in_file(source_path('_layouts/default.html'), match_snippet, replacement_snippet)
        end

        generate_site(:production, clear_cache: false)

        new_mtime = mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        assert_operator new_mtime, :>, org_mtime
      end
    end

    def test_changing_asset_source_list_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        match_snippet = <<-END
    assets:
      - dependency
      - app
        END

        replacement_snippet = <<-END
    assets:
      - dependency
        END

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), match_snippet, replacement_snippet)
        end

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = 'assets/site-71042d0b7c86c04e015fde694dd9f409.js'

        assert_equal new_destination, find_js_path_from_index
        assert File.exist?(destination_path(new_destination))
      end
    end

    def test_changing_asset_source_list_removes_old_temporary_bundle_file
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        match_snippet = <<-END
    assets:
      - dependency
      - app
        END

        replacement_snippet = <<-END
    assets:
      - dependency
        END

        org_tempfiles = find_tempfiles

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), match_snippet, replacement_snippet)
        end

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert File.exist?(destination_path('assets/site-71042d0b7c86c04e015fde694dd9f409.js'))
        assert_equal 1, (org_tempfiles - find_tempfiles).size
      end
    end

    def test_changing_asset_destination_path_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = "assets/site2-#{JS_BUNDLE_FINGERPRINT}.js"

        assert_equal new_destination, find_js_path_from_index
        assert File.exist?(destination_path(new_destination))
      end
    end

    def test_changing_asset_destination_path_removes_old_temporary_bundle_file
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        org_tempfiles = find_tempfiles

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        sleep 1  # wait for unlinked temp files to actually disappear

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert File.exist?(destination_path("assets/site2-#{JS_BUNDLE_FINGERPRINT}.js"))
        assert_equal 1, (org_tempfiles - find_tempfiles).size
      end
    end

    def test_changing_asset_destination_path_to_new_value_and_back_to_original_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = "assets/site2-#{JS_BUNDLE_FINGERPRINT}.js"

        assert_equal new_destination, find_js_path_from_index
        assert File.exist?(destination_path(new_destination))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site2', 'assets/site')
        end

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(new_destination))
        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_changing_minifier_cmd_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert_equal 0, get_minifier_cmd_count
        destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = mtime_of(destination)

        match_snippet = <<-END
    {% minibundle js %}
        END

        replacement_snippet = <<-END
    {% minibundle js %}
    minifier_cmd: #{minifier_cmd_to_remove_comments_and_count}
        END

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), match_snippet, replacement_snippet)
        end

        generate_site(:production, clear_cache: false)

        assert_equal 1, get_minifier_cmd_count
        assert_operator mtime_of(destination), :>, org_mtime
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        assert_equal CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index

        find_and_gsub_in_file(source_path('_layouts/default.html'), 'destination_path: assets/site', 'destination_path: /assets/site')

        generate_site(:production, clear_cache: false)

        assert_equal "/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index
        assert_equal "/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index
      end
    end

    def test_supports_baseurl
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        assert_equal CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index

        find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle css %}', "{% minibundle css %}\n    baseurl: /css-root")
        find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle js %}', "{% minibundle js %}\n    baseurl: /js-root")

        generate_site(:production, clear_cache: false)

        assert_equal "/css-root/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index
        assert_equal "/js-root/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index
      end
    end

    def test_supports_baseurl_via_liquid_variable
      with_site_dir do
        merge_to_yaml_file(source_path('_config.yml'), 'baseurl' => '/')
        find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle css %}', "{% minibundle css %}\n    baseurl: {{ site.baseurl }}")
        find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle js %}', "{% minibundle js %}\n    baseurl: {{ site.baseurl }}")

        generate_site(:production)

        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        assert_equal "/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index
        assert_equal "/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index
      end
    end

    def test_supports_changing_attributes
      with_site_dir do
        generate_site(:production)

        assert_equal CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index

        find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-styles', 'id: my-styles2')
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-scripts', 'id: my-scripts2')

        generate_site(:production, clear_cache: false)

        assert_equal 'my-styles2', find_css_element_from_index['id']
        assert_equal 'my-scripts2', find_js_element_from_index['id']
      end
    end

    def test_bundles_assets_only_once_at_startup
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)
        assert_equal 1, get_minifier_cmd_count
      end
    end

    def test_does_not_rebundle_assets_when_changing_nonsource_files
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = mtime_of(expected_js_path)

        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes { File.write(source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css'), 'h1 {}') }

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal org_mtime, mtime_of(expected_js_path)
        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes { FileUtils.touch('index.html') }

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal org_mtime, mtime_of(expected_js_path)
        assert_equal 1, get_minifier_cmd_count
      end
    end

    def test_does_not_rebundle_assets_when_changing_attributes
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = mtime_of(expected_js_path)

        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-scripts', 'id: my-scripts2')
        end

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal org_mtime, mtime_of(expected_js_path)
        assert_equal 1, get_minifier_cmd_count
      end
    end

    def test_does_not_rebundle_assets_when_changing_baseurl
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = mtime_of(expected_js_path)

        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle js %}', "{% minibundle js %}\n    baseurl: /js-root")
        end

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal org_mtime, mtime_of(expected_js_path)
        assert_equal 1, get_minifier_cmd_count
      end
    end

    def test_gets_minifier_command_from_site_configuration
      with_site_dir do
        merge_to_yaml_file(
          source_path('_config.yml'),
          'minibundle' => {'minifier_commands' => {'js' => minifier_cmd_to_remove_comments_and_count('minifier_cmd_config_count')}}
        )

        generate_site(:production, minifier_cmd_js: nil)

        assert_equal 0, get_minifier_cmd_count
        assert_equal 1, get_minifier_cmd_count('minifier_cmd_config_count')
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_minifier_command_from_environment_overrides_command_from_site_configuration
      with_site_dir do
        merge_to_yaml_file(
          source_path('_config.yml'),
          'minibundle' => {'minifier_commands' => {'js' => minifier_cmd_to_remove_comments_and_count('minifier_cmd_config_count')}}
        )

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
      assets
        .map { |f| File.read(site_fixture_path(source_subdir, "#{f}.#{type}")) }
        .join('')
        .size
    end

    def change_destination_path_in_minibundle_block(from, to)
      match_snippet = <<-END
    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: #{from}
      END

      replacement_snippet = <<-END
    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: #{to}
      END

      find_and_gsub_in_file(source_path('_layouts/default.html'), match_snippet, replacement_snippet)
    end

    def find_tempfiles
      Dir[File.join(Dir.tmpdir, AssetBundle::TEMPFILE_PREFIX + '*')]
    end
  end
end
