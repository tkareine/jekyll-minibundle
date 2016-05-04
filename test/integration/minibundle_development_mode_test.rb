require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MinibundleDevelopmentModeTest < TestCase
    include FixtureConfig

    CSS_ASSET_DESTINATION_PATHS = %w{reset common}.map { |f| File.join(CSS_BUNDLE_DESTINATION_PATH, "#{f}.css") }
    JS_ASSET_DESTINATION_PATHS = %w{dependency app}.map { |f| File.join(JS_BUNDLE_DESTINATION_PATH, "#{f}.js") }

    def test_css_assets_have_tags_in_configured_order
      with_precompiled_site(:development) do
        assert_equal CSS_ASSET_DESTINATION_PATHS, find_css_paths_from_index
      end
    end

    def test_js_assets_have_tags_in_configured_order
      with_precompiled_site(:development) do
        assert_equal JS_ASSET_DESTINATION_PATHS, find_js_paths_from_index
      end
    end

    def test_css_assets_have_configured_attributes
      with_precompiled_site(:development) do
        elements = find_css_elements_from_index.map { |el| [el['id'], el['media']] }.uniq
        assert_equal [['my-styles', 'projection']], elements
      end
    end

    def test_js_assets_have_configured_attributes
      with_precompiled_site(:development) do
        elements = find_js_elements_from_index.map { |el| [el['id'], el['async']] }.uniq
        assert_equal [['my-scripts', '']], elements
      end
    end

    def test_copies_css_assets_to_destination_dir
      with_precompiled_site(:development) do
        CSS_ASSET_DESTINATION_PATHS.each do |path|
          expect_file_exists_and_is_equal_to(destination_path(path), site_fixture_path(CSS_BUNDLE_SOURCE_DIR, File.basename(path)))
        end
      end
    end

    def test_copies_js_assets_to_destination_dir
      with_precompiled_site(:development) do
        JS_ASSET_DESTINATION_PATHS.each do |path|
          expect_file_exists_and_is_equal_to(destination_path(path), site_fixture_path(JS_BUNDLE_SOURCE_DIR, File.basename(path)))
        end
      end
    end

    [
      {desc: 'changing', action: ->(source) { File.write(source, '(function() {})()') }},
      {desc: 'touching', action: ->(source) { FileUtils.touch(source) }}
    ].each do |spec|
      define_method :"test_#{spec.fetch(:desc)}_asset_source_file_rewrites_destination" do
        with_site_dir do
          generate_site(:development)

          destination = destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js')
          org_mtime = mtime_of(destination)
          source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
          ensure_file_mtime_changes { spec.fetch(:action).call(source) }

          generate_site(:development, clear_cache: false)

          assert_equal File.read(destination), File.read(source)
          assert_operator mtime_of(destination), :>, org_mtime
        end
      end
    end

    def test_changing_asset_source_directory_rewrites_destination
      with_site_dir do
        generate_site(:development)

        destination = destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js')
        org_mtime = mtime_of(destination)

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

        generate_site(:development, clear_cache: false)

        assert_operator mtime_of(destination), :>, org_mtime
      end
    end

    def test_changing_asset_source_list_rewrites_destination
      with_site_dir do
        generate_site(:development)

        org_mtime = mtime_of(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))

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

        generate_site(:development, clear_cache: false)

        assert_equal [File.join(JS_BUNDLE_DESTINATION_PATH, 'dependency.js')], find_js_paths_from_index

        new_mtime = mtime_of(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))
        assert_operator new_mtime, :>, org_mtime
      end
    end

    def test_changing_asset_destination_path_rewrites_destination
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:development, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))
        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        assert_equal ['assets/site2/dependency.js', 'assets/site2/app.js'], find_js_paths_from_index
        assert File.exist?(destination_path('assets/site2/dependency.js'))
        assert File.exist?(destination_path('assets/site2/app.js'))
      end
    end

    def test_changing_asset_destination_path_to_new_value_and_back_to_original_rewrites_destination
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site', 'assets/site2')
        end

        generate_site(:development, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))
        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        assert_equal ['assets/site2/dependency.js', 'assets/site2/app.js'], find_js_paths_from_index
        assert File.exist?(destination_path('assets/site2/dependency.js'))
        assert File.exist?(destination_path('assets/site2/app.js'))

        ensure_file_mtime_changes do
          change_destination_path_in_minibundle_block('assets/site2', 'assets/site')
        end

        generate_site(:development, clear_cache: false)

        refute File.exist?(destination_path('assets/site2/dependency.js'))
        refute File.exist?(destination_path('assets/site2/app.js'))

        assert_equal ['assets/site/dependency.js', 'assets/site/app.js'], find_js_paths_from_index
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js'))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_PATH, 'common.css'))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        assert_equal 'assets/site/common.css', find_css_paths_from_index.last
        assert_equal 'assets/site/app.js', find_js_paths_from_index.last

        find_and_gsub_in_file(source_path('_layouts/default.html'), 'destination_path: assets/site', 'destination_path: /assets/site')

        generate_site(:development, clear_cache: false)

        assert_equal '/assets/site/common.css', find_css_paths_from_index.last
        assert_equal '/assets/site/app.js', find_js_paths_from_index.last
      end
    end

    def test_supports_baseurl
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_PATH, 'common.css'))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        assert_equal 'assets/site/common.css', find_css_paths_from_index.last
        assert_equal 'assets/site/app.js', find_js_paths_from_index.last

        find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle css %}', "{% minibundle css %}\n    baseurl: /css-root")
        find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle js %}', "{% minibundle js %}\n    baseurl: /js-root")

        generate_site(:development, clear_cache: false)

        assert_equal '/css-root/assets/site/common.css', find_css_paths_from_index.last
        assert_equal '/js-root/assets/site/app.js', find_js_paths_from_index.last
      end
    end

    def test_supports_changing_attributes
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(CSS_BUNDLE_DESTINATION_PATH, 'common.css'))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))

        find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-styles', 'id: my-styles2')
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-scripts', 'id: my-scripts2')

        generate_site(:development, clear_cache: false)

        css_ids = find_css_elements_from_index.map { |el| el['id'] }.uniq
        assert_equal ['my-styles2'], css_ids

        js_ids = find_js_elements_from_index.map { |el| el['id'] }.uniq
        assert_equal ['my-scripts2'], js_ids
      end
    end

    def test_does_not_require_bundling_commands
      with_site_dir do
        generate_site(:development, minifier_cmd_css: nil, minifier_cmd_js: nil)
        pass
      end
    end

    def test_does_not_rewrite_destination_when_changing_nonsource_files
      with_site_dir do
        generate_site(:development)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js')
        org_mtime = mtime_of(expected_js_path)
        ensure_file_mtime_changes { File.write(source_path(JS_BUNDLE_SOURCE_DIR, 'dependency.js'), '(function() {})()') }

        generate_site(:development, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_js_path)

        ensure_file_mtime_changes { FileUtils.touch('index.html') }

        generate_site(:development, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_js_path)
      end
    end

    def test_does_not_rewrite_destination_when_changing_attributes
      with_site_dir do
        generate_site(:development)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js')
        org_mtime = mtime_of(expected_js_path)

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), 'id: my-scripts', 'id: my-scripts2')
        end

        generate_site(:development, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_js_path)
      end
    end

    def test_does_not_rebundle_assets_when_changing_baseurl
      with_site_dir do
        generate_site(:development)

        expected_js_path = destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js')
        org_mtime = mtime_of(expected_js_path)

        ensure_file_mtime_changes do
          find_and_gsub_in_file(source_path('_layouts/default.html'), '{% minibundle js %}', "{% minibundle js %}\n    baseurl: /js-root")
        end

        generate_site(:development, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_js_path)
      end
    end

    def test_gets_development_mode_from_site_configuration
      with_site_dir do
        merge_to_yaml_file('_config.yml', 'minibundle' => {'mode' => 'development'})
        generate_site(nil)
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))
      end
    end

    def test_development_mode_from_environment_overrides_mode_from_site_configuration
      with_site_dir do
        merge_to_yaml_file('_config.yml', 'minibundle' => {'mode' => 'production'})
        generate_site(:development)
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_PATH, 'app.js'))
      end
    end

    private

    def find_css_elements_from_index
      find_html_elements_from_index('head link[media!="screen"]')
    end

    def find_css_paths_from_index
      find_css_elements_from_index.map { |el| el['href'] }
    end

    def find_js_elements_from_index
      find_html_elements_from_index('body script')
    end

    def find_js_paths_from_index
      find_js_elements_from_index.map { |el| el['src'] }
    end

    def find_html_elements_from_index(css)
      find_html_element(File.read(destination_path('index.html')), css)
    end

    def expect_file_exists_and_is_equal_to(actual, expected)
      assert File.exist?(actual)
      assert_equal File.read(expected), File.read(actual)
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
  end
end
