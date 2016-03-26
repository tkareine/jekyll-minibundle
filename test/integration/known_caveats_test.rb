require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  # Known caveats that won't be fixed in the current design of the
  # plugin.
  class KnownCaveatsTest < TestCase
    include FixtureConfig

    # In Jekyll's watch (auto-regeneration) mode, changing asset
    # destination path to a new value triggers the plugin to rebundle
    # the assets and writing the bundle file to site output
    # directory. After that, changing the destination path back to the
    # original value should cause the plugin to write the original
    # bundle file to site output directory again. This should happen
    # without rebundling the assets, because the plugin stores the
    # original bundle in a temporary file.
    #
    # The plugin cannot rewrite the original bundle file to site
    # output directory, because it does not get a trigger for doing
    # so. The plugin has a non-expiring cumulative cache for
    # assets. This allows the plugin to avoid rebundling assets in
    # site regeneration if the assets themselves are unchanged.  This
    # same mechanism is the cause for this caveat.
    #
    # As a workaround, touching or changing one of the assets in the
    # bundle triggers rebundling and rewriting the bundle file to site
    # output directory.
    #
    # For now, we have decided that the caveat is a minor drawback
    # compared to the benefit of avoiding unnecessary rebundling in
    # site regeneration.
    def test_changing_asset_destination_path_to_new_value_and_back_to_original_does_not_rewrite_destination
      with_site_dir do
        generate_site(:production)

        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        ensure_file_mtime_changes do
          change_destination_path('assets/site', 'assets/site2')
        end

        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))

        new_destination = "assets/site2-#{JS_BUNDLE_FINGERPRINT}.js"

        assert_equal new_destination, find_js_path_from_index
        assert File.exist?(destination_path(new_destination))

        ensure_file_mtime_changes do
          change_destination_path('assets/site2', 'assets/site')

          # CAVEAT: This should not be needed.
          FileUtils.touch(source_path('_assets/scripts/dependency.js'))
        end

        generate_site(:production, clear_cache: false)

        assert_equal JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, find_js_path_from_index
        refute File.exist?(destination_path(new_destination))
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
      end
    end

    private

    def change_destination_path(from, to)
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

    def find_js_path_from_index
      find_html_element(File.read(destination_path('index.html')), 'body script').first['src']
    end
  end
end
