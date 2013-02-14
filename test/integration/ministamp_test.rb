require 'support/test_case'

module Jekyll::Minibundle::Test
  class MiniStampTest < TestCase
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
        source_contents = File.read site_fixture_path('_tmp/site.css')
        destination_contents = File.read destination_path(EXPECTED_ASSET_PATH)
        assert_equal source_contents, destination_contents
      end
    end
  end
end
