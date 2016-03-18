require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MiniStampTest < TestCase
    include FixtureConfig

    def test_asset_destination_path_has_no_stamp_in_development_mode
      with_precompiled_site(:development) do
        assert_equal STAMP_DESTINATION_PATH, find_css_path_from_index
        assert File.exist?(destination_path(STAMP_DESTINATION_PATH))
      end
    end

    def test_asset_destination_path_has_stamp_in_production_mode
      with_precompiled_site(:production) do
        assert_equal STAMP_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
        assert File.exist?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_contents_of_asset_destination_are_equal_to_source
      with_precompiled_site(:production) do
        source_contents = File.read(site_fixture_path(STAMP_SOURCE_PATH))
        destination_contents = File.read(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
        assert_equal source_contents, destination_contents
      end
    end

    def test_changing_asset_source_rewrites_destination
      with_site_dir do
        generate_site(:production)
        org_mtime = mtime_of(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
        ensure_file_mtime_changes { File.write(source_path(STAMP_SOURCE_PATH), 'h1 {}') }
        generate_site(:production, clear_cache: false)

        refute File.exist?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))

        new_destination = 'assets/screen-0f5dbd1e527a2bee267e85007b08d2a5.css'

        assert_equal new_destination, find_css_path_from_index
        assert File.exist?(destination_path(new_destination))
        assert_operator mtime_of(destination_path(new_destination)), :>, org_mtime
      end
    end

    def test_touching_asset_source_rewrites_destination
      with_site_dir do
        generate_site(:production)
        destination = STAMP_DESTINATION_FINGERPRINT_PATH
        org_mtime = mtime_of(destination_path(destination))
        ensure_file_mtime_changes { FileUtils.touch(source_path(STAMP_SOURCE_PATH)) }
        generate_site(:production, clear_cache: false)

        assert_equal destination, find_css_path_from_index
        assert File.exist?(destination_path(destination))
        assert_operator mtime_of(destination_path(destination)), :>, org_mtime
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site_dir do
        generate_site(:production)
        expected_path = destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)

        assert File.exist?(expected_path)
        assert_equal STAMP_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index

        find_and_gsub_in_file(source_path('_layouts/default.html'), %r{assets/screen.css}, '/\0')
        generate_site(:production, clear_cache: false)

        assert_equal "/#{STAMP_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index
      end
    end

    def test_does_not_rewrite_destination_when_nonsource_files_change
      with_site_dir do
        generate_site(:production)
        expected_path = destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)
        org_mtime = mtime_of(expected_path)
        ensure_file_mtime_changes { File.write(source_path(JS_BUNDLE_SOURCE_DIR, 'dependency.js'), '(function() {})()') }
        generate_site(:production, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_path)

        ensure_file_mtime_changes { FileUtils.touch('index.html') }
        generate_site(:production, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_path)
      end
    end

    private

    def find_css_path_from_index
      find_html_element(File.read(destination_path('index.html')), 'head link').first['href']
    end
  end
end
