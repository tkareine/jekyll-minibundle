require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MinibundleProductionModeTest < TestCase
    include FixtureConfig

    def test_css_asset_bundle_has_stamp
      with_precompiled_site(:production) do
        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
      end
    end

    def test_js_asset_bundle_has_stamp
      with_precompiled_site(:production) do
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)
      end
    end

    def test_css_asset_bundle_has_configured_attributes
      with_precompiled_site(:production) do
        element = find_css_element_from_index
        assert_equal('my-styles', element['id'])
        assert_equal('projection', element['media'])
      end
    end

    def test_js_asset_bundle_has_configured_attributes
      with_precompiled_site(:production) do
        element = find_js_element_from_index
        assert_equal('my-scripts', element['id'])
        assert_equal('', element['async'])
      end
    end

    def test_copies_css_asset_bundle_to_destination_dir
      with_precompiled_site(:production) do
        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
      end
    end

    def test_copies_js_asset_bundle_to_destination_dir
      with_precompiled_site(:production) do
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
      end
    end

    def test_concatenates_css_asset_bundle_in_configured_order
      with_precompiled_site(:production) do
        bundle = File.read(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_operator(bundle.index('html { margin: 0; }'), :<, bundle.index('p { margin: 0; }'))
      end
    end

    def test_concatenates_js_asset_bundle_in_configured_order
      with_precompiled_site(:production) do
        bundle = File.read(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_operator(bundle.index('root.dependency = {};'), :<, bundle.index('root.app = {};'))
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
        assert_operator(destination_contents_size, :<, source_contents_size)
      end
    end

    def test_minifies_js_asset_bundle
      with_precompiled_site(:production) do
        source_contents_size = source_assets_size(JS_BUNDLE_SOURCE_DIR, %w{dependency app}, 'js')
        destination_contents_size = File.read(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)).size
        assert_operator(destination_contents_size, :<, source_contents_size)
      end
    end

    def test_changing_asset_source_file_rewrites_destination
      with_site_dir do
        generate_site(:production)

        ensure_file_mtime_changes { File.write(source_path(JS_BUNDLE_SOURCE_DIR, 'app.js'), '(function() {})()') }

        generate_site(:production, clear_cache: false)

        refute(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        new_destination = 'assets/site-375a0b430b0c5555d0edd2205d26c04d.js'

        assert_equal(new_destination, find_js_path_from_index)
        assert(File.file?(destination_path(new_destination)))
      end
    end

    def test_touching_asset_source_file_rewrites_destination
      with_site_dir do
        generate_site(:production)

        org_mtime = file_mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        ensure_file_mtime_changes { FileUtils.touch(source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')) }

        generate_site(:production, clear_cache: false)

        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert_operator(file_mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)), :>, org_mtime)
      end
    end

    def test_changing_asset_source_directory_rewrites_destination
      with_site_dir do
        generate_site(:production)

        org_mtime = file_mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

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

        new_mtime = file_mtime_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        assert_operator(new_mtime, :>, org_mtime)
      end
    end

    def test_changing_asset_source_list_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

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

        refute(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        new_destination = 'assets/site-71042d0b7c86c04e015fde694dd9f409.js'

        assert_equal(new_destination, find_js_path_from_index)
        assert(File.file?(destination_path(new_destination)))
      end
    end

    def test_changing_asset_source_list_removes_old_temporary_bundle_file
      with_site_dir do
        other_tempfiles = find_tempfiles('*.js')

        generate_site(:production)

        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        match_snippet = <<-END
    assets:
      - dependency
      - app
        END

        replacement_snippet = <<-END
    assets:
      - dependency
        END

        old_tempfiles = find_tempfiles('*.js') - other_tempfiles

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), match_snippet, replacement_snippet)
        end

        generate_site(:production, clear_cache: false)

        refute(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path('assets/site-71042d0b7c86c04e015fde694dd9f409.js')))
        assert((find_tempfiles('*.js') & old_tempfiles).empty?)
      end
    end

    def test_changing_asset_destination_path_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        refute(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        new_destination = "assets/site2-#{JS_BUNDLE_FINGERPRINT}.js"

        assert_equal(new_destination, find_js_path_from_index)
        assert(File.file?(destination_path(new_destination)))
      end
    end

    def test_changing_asset_destination_path_removes_old_temporary_bundle_file
      with_site_dir do
        other_tempfiles = find_tempfiles('*.js')

        generate_site(:production)

        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        old_tempfiles = find_tempfiles('*.js') - other_tempfiles

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        refute(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path("assets/site2-#{JS_BUNDLE_FINGERPRINT}.js")))
        assert((find_tempfiles('*.js') & old_tempfiles).empty?)
      end
    end

    def test_changing_asset_destination_path_to_new_value_and_back_to_original_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        refute(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        new_destination = "assets/site2-#{JS_BUNDLE_FINGERPRINT}.js"

        assert_equal(new_destination, find_js_path_from_index)
        assert(File.file?(destination_path(new_destination)))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site2', 'assets/site')
        end

        generate_site(:production, clear_cache: false)

        refute(File.file?(destination_path(new_destination)))
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
      end
    end

    def test_changing_minifier_cmd_rewrites_destination
      with_site_dir do
        generate_site(:production)

        assert_equal(0, get_minifier_cmd_count)
        destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = file_mtime_of(destination)

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

        assert_equal(1, get_minifier_cmd_count)
        assert_operator(file_mtime_of(destination), :>, org_mtime)
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site_dir do
        generate_site(:production)

        destination_css = destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        destination_js = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime_css = file_mtime_of(destination_css)
        org_mtime_js = file_mtime_of(destination_js)

        assert(File.file?(destination_css))
        assert(File.file?(destination_js))

        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)

        ensure_file_mtime_changes do
          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            'destination_path: assets/site',
            'destination_path: /assets/site'
          )
        end

        generate_site(:production, clear_cache: false)

        assert(File.file?(destination_css))
        assert(File.file?(destination_js))
        assert_equal(org_mtime_css, file_mtime_of(destination_css))
        assert_equal(org_mtime_js, file_mtime_of(destination_js))
        assert_equal("/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index)
        assert_equal("/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index)
      end
    end

    def test_supports_baseurl
      with_site_dir do
        merge_to_yaml_file(source_path('_config.yml'), 'baseurl' => '/root')

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle css %}',
          <<-END
    {% minibundle css %}
    baseurl: '{{ site.baseurl }}/'
          END
        )

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle js %}',
          <<-END
    {% minibundle js %}
    baseurl: {{ site.baseurl }}/js
          END
        )

        generate_site(:production)

        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        assert_equal("/root/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index)
        assert_equal("/root/js/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index)
      end
    end

    def test_strips_dot_slash_from_dot_baseurl
      with_site_dir do
        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle css %}',
          <<-END
    {% minibundle css %}
    baseurl: .
          END
        )

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle js %}',
          <<-END
    {% minibundle js %}
    baseurl: .
          END
        )

        generate_site(:production)

        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)

        generate_site(:production, clear_cache: false)

        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)
      end
    end

    def test_strips_dot_slash_from_dot_slash_baseurl
      with_site_dir do
        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle css %}',
          <<-END
    {% minibundle css %}
    baseurl: ./
          END
        )

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle js %}',
          <<-END
    {% minibundle js %}
    baseurl: ./
          END
        )

        generate_site(:production)

        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)

        generate_site(:production, clear_cache: false)

        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))

        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)
      end
    end

    def test_strips_dot_slash_from_relative_destination_path
      with_site_dir do
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'destination_path: assets/site', 'destination_path: site')

        generate_site(:production)

        assert(File.file?(destination_path("site-#{CSS_BUNDLE_FINGERPRINT}.css")))
        assert(File.file?(destination_path("site-#{JS_BUNDLE_FINGERPRINT}.js")))

        assert_equal("site-#{CSS_BUNDLE_FINGERPRINT}.css", find_css_path_from_index)
        assert_equal("site-#{JS_BUNDLE_FINGERPRINT}.js", find_js_path_from_index)

        generate_site(:production, clear_cache: false)

        assert(File.file?(destination_path("site-#{CSS_BUNDLE_FINGERPRINT}.css")))
        assert(File.file?(destination_path("site-#{JS_BUNDLE_FINGERPRINT}.js")))

        assert_equal("site-#{CSS_BUNDLE_FINGERPRINT}.css", find_css_path_from_index)
        assert_equal("site-#{JS_BUNDLE_FINGERPRINT}.js", find_js_path_from_index)
      end
    end

    def test_strips_dot_slash_from_dot_slash_destination_path
      with_site_dir do
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'destination_path: assets/site', 'destination_path: ./site')

        generate_site(:production)

        assert(File.file?(destination_path("site-#{CSS_BUNDLE_FINGERPRINT}.css")))
        assert(File.file?(destination_path("site-#{JS_BUNDLE_FINGERPRINT}.js")))

        assert_equal("site-#{CSS_BUNDLE_FINGERPRINT}.css", find_css_path_from_index)
        assert_equal("site-#{JS_BUNDLE_FINGERPRINT}.js", find_js_path_from_index)

        generate_site(:production, clear_cache: false)

        assert(File.file?(destination_path("site-#{CSS_BUNDLE_FINGERPRINT}.css")))
        assert(File.file?(destination_path("site-#{JS_BUNDLE_FINGERPRINT}.js")))

        assert_equal("site-#{CSS_BUNDLE_FINGERPRINT}.css", find_css_path_from_index)
        assert_equal("site-#{JS_BUNDLE_FINGERPRINT}.js", find_js_path_from_index)
      end
    end

    def test_supports_destination_baseurl
      with_site_dir do
        merge_to_yaml_file(source_path('_config.yml'), 'cdn_baseurl' => 'https://cdn.example.com/?file=')

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '    {% minibundle css %}',
          <<-END
    {% minibundle css %}
    baseurl: /ignored
    destination_baseurl: {{ site.cdn_baseurl }}css/
          END
        )

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          /    #{Regexp.escape('{% minibundle js %}')}.*#{Regexp.escape('{% endminibundle %}')}/m,
          <<-END
    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: static
    baseurl: /ignored
    destination_baseurl: '{{ site.cdn_baseurl }}'
    assets:
      - dependency
      - app
    {% endminibundle %}
          END
        )

        generate_site(:production)

        assert(File.file?(destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        assert(File.file?(destination_path("static-#{JS_BUNDLE_FINGERPRINT}.js")))

        assert_equal("https://cdn.example.com/?file=css/site-#{CSS_BUNDLE_FINGERPRINT}.css", find_css_path_from_index)
        assert_equal("https://cdn.example.com/?file=static-#{JS_BUNDLE_FINGERPRINT}.js", find_js_path_from_index)
      end
    end

    def test_supports_changing_attributes
      with_site_dir do
        generate_site(:production)

        assert_equal(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index)
        assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index)

        find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-styles', 'id: my-styles2')
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-scripts', 'id: my-scripts2')

        generate_site(:production, clear_cache: false)

        assert_equal('my-styles2', find_css_element_from_index['id'])
        assert_equal('my-scripts2', find_js_element_from_index['id'])
      end
    end

    def test_bundles_assets_only_once_at_startup
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)
        assert_equal(1, get_minifier_cmd_count)
      end
    end

    def test_does_not_rebundle_assets_when_changing_nonsource_files
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = file_mtime_of(expected_js_path)

        assert_equal(1, get_minifier_cmd_count)

        ensure_file_mtime_changes { File.write(source_path(CSS_BUNDLE_SOURCE_DIR, 'common.css'), 'h1 {}') }

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal(org_mtime, file_mtime_of(expected_js_path))
        assert_equal(1, get_minifier_cmd_count)

        ensure_file_mtime_changes { FileUtils.touch('index.html') }

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal(org_mtime, file_mtime_of(expected_js_path))
        assert_equal(1, get_minifier_cmd_count)
      end
    end

    def test_does_not_rebundle_assets_when_changing_attributes
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = file_mtime_of(expected_js_path)

        assert_equal(1, get_minifier_cmd_count)

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-scripts', 'id: my-scripts2')
        end

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal(org_mtime, file_mtime_of(expected_js_path))
        assert_equal(1, get_minifier_cmd_count)
      end
    end

    def test_does_not_rebundle_assets_when_changing_baseurl
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = file_mtime_of(expected_js_path)

        assert_equal(1, get_minifier_cmd_count)

        ensure_file_mtime_changes do
          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            '    {% minibundle js %}',
            <<-END
    {% minibundle js %}
    baseurl: /js-root
            END
          )
        end

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal(org_mtime, file_mtime_of(expected_js_path))
        assert_equal(1, get_minifier_cmd_count)
        assert_equal("/js-root/#{JS_BUNDLE_DESTINATION_FINGERPRINT_PATH}", find_js_path_from_index)
      end
    end

    def test_does_not_rebundle_assets_when_changing_destination_baseurl
      with_site_dir do
        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_mtime = file_mtime_of(expected_js_path)

        assert_equal(1, get_minifier_cmd_count)

        ensure_file_mtime_changes do
          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            '    {% minibundle js %}',
            <<-END
    {% minibundle js %}
    destination_baseurl: /root/
            END
          )
        end

        generate_site(:production, clear_cache: false, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count)

        assert_equal(org_mtime, file_mtime_of(expected_js_path))
        assert_equal(1, get_minifier_cmd_count)
        assert_equal("/root/site-#{JS_BUNDLE_FINGERPRINT}.js", find_js_path_from_index)
      end
    end

    def test_gets_minifier_command_from_site_configuration
      with_site_dir do
        merge_to_yaml_file(
          source_path('_config.yml'),
          'minibundle' => {'minifier_commands' => {'js' => minifier_cmd_to_remove_comments_and_count('minifier_cmd_config_count')}}
        )

        generate_site(:production, minifier_cmd_js: nil)

        assert_equal(0, get_minifier_cmd_count)
        assert_equal(1, get_minifier_cmd_count('minifier_cmd_config_count'))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
      end
    end

    def test_minifier_command_from_environment_overrides_command_from_site_configuration
      with_site_dir do
        merge_to_yaml_file(
          source_path('_config.yml'),
          'minibundle' => {'minifier_commands' => {'js' => minifier_cmd_to_remove_comments_and_count('minifier_cmd_config_count')}}
        )

        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count('minifier_cmd_env_count'))

        assert_equal(0, get_minifier_cmd_count('minifier_cmd_config_count'))
        assert_equal(1, get_minifier_cmd_count('minifier_cmd_env_count'))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
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
</html>
        END

        generate_site(:production, minifier_cmd_js: minifier_cmd_to_remove_comments_and_count('minifier_cmd_global_count'))

        assert_equal(1, get_minifier_cmd_count('minifier_cmd_local_count'))
        assert(File.file?(destination_path('assets/deps-71042d0b7c86c04e015fde694dd9f409.js')))

        assert_equal(1, get_minifier_cmd_count('minifier_cmd_global_count'))
        assert(File.file?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
      end
    end

    def test_destination_file_respects_umask
      with_site_dir do
        with_umask(0o027) do
          generate_site(:production)
          assert_equal(0o640, file_permissions_of(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)))
        end
      end
    end

    def test_escapes_destination_path_url_and_attributes_in_generated_html_element
      with_site_dir do
        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          /    #{Regexp.escape('{% minibundle js %}')}.*#{Regexp.escape('{% endminibundle %}')}/m,
          <<-END
    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: 'dst">'
    assets:
      - dependency
      - app
    attributes:
      test: '"/><br>'
    {% endminibundle %}
          END
        )

        generate_site(:production)

        assert(File.file?(destination_path(%{dst">-#{JS_BUNDLE_FINGERPRINT}.js})))
        assert_equal(%{dst">-#{JS_BUNDLE_FINGERPRINT}.js}, find_js_path_from_index)
        assert_equal('"/><br>', find_js_element_from_index['test'])
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

    def find_tempfiles(glob)
      Dir[File.join(Dir.tmpdir, AssetBundle::TEMPFILE_PREFIX + glob)]
    end
  end
end
