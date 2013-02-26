require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MiniStampTest < TestCase
    include FixtureConfig

    def test_asset_destination_path_has_no_stamp_in_development_mode
      with_precompiled_site :development do
        assert_equal STAMP_DESTINATION_PATH, find_css_path_from_index
      end
    end

    def test_asset_destination_path_has_stamp_in_production_mode
      with_precompiled_site :production do
        assert_equal STAMP_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index
      end
    end

    def test_asset_file_is_copied_to_destination_dir
      with_precompiled_site :production do
        assert File.exists?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
      end
    end

    def test_asset_file_is_equal_to_source_file
      with_precompiled_site :production do
        source_contents = File.read site_fixture_path(STAMP_SOURCE_PATH)
        destination_contents = File.read destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)
        assert_equal source_contents, destination_contents
      end
    end

    def test_change_asset_file
      with_site do
        generate_site :production
        assert File.exists?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
        File.write source_path(STAMP_SOURCE_PATH), 'h1 {}'
        generate_site :production
        refute File.exists?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
        expected_new_path = 'assets/screen-0f5dbd1e527a2bee267e85007b08d2a5.css'
        assert_equal expected_new_path, find_css_path_from_index
        assert File.exists?(destination_path(expected_new_path))
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site do
        generate_site :production
        expected_path = destination_path STAMP_DESTINATION_FINGERPRINT_PATH

        assert File.exists?(expected_path)
        assert_equal STAMP_DESTINATION_FINGERPRINT_PATH, find_css_path_from_index

        find_and_gsub_in_file(source_path('index.html'), %r{assets/screen.css}, '/\0')

        generate_site :production

        assert File.exists?(expected_path)
        assert_equal "/#{STAMP_DESTINATION_FINGERPRINT_PATH}", find_css_path_from_index
      end
    end

    def test_do_not_copy_source_when_other_files_change
      with_site do
        generate_site :production
        expected_path = destination_path STAMP_DESTINATION_FINGERPRINT_PATH
        org_mtime = mtime_of expected_path
        ensure_file_mtime_changes { File.write source_path(JS_BUNDLE_SOURCE_DIR, 'dependency.js'), '(function() {})()' }
        generate_site :production

        assert_equal org_mtime, mtime_of(expected_path)

        ensure_file_mtime_changes { FileUtils.touch 'index.html' }
        generate_site :production

        assert_equal org_mtime, mtime_of(expected_path)
      end
    end

    private

    def find_css_path_from_index
      find_html_element(File.read(destination_path('index.html')), 'head link').first['href']
    end
  end
end
