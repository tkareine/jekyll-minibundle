require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MiniStampTest < TestCase
    include FixtureConfig

    EXPECTED_ASSET_PATH = 'assets/screen-390be921ee0eff063817bb5ef2954300.css'

    def test_asset_path_has_stamp
      with_precompiled_site :production do
        actual = find_html_element(File.read(destination_path('index.html')), 'head link').first['href']
        assert_equal EXPECTED_ASSET_PATH, actual
      end
    end

    def test_asset_file_is_copied_to_destination_dir
      with_precompiled_site :production do
        assert File.exists?(destination_path(EXPECTED_ASSET_PATH))
      end
    end

    def test_asset_file_is_equal_to_source_file
      with_precompiled_site :production do
        source_contents = File.read site_fixture_path(CSS_STAMP_SOURCE_FILE)
        destination_contents = File.read destination_path(EXPECTED_ASSET_PATH)
        assert_equal source_contents, destination_contents
      end
    end

    def test_change_asset_file
      with_site do
        generate_site :production
        assert File.exists?(destination_path(EXPECTED_ASSET_PATH))
        File.write source_path(CSS_STAMP_SOURCE_FILE), 'h1 {}'
        generate_site :production
        refute File.exists?(destination_path(EXPECTED_ASSET_PATH))
        assert File.exists?(destination_path('assets/screen-0f5dbd1e527a2bee267e85007b08d2a5.css'))
      end
    end
  end
end
