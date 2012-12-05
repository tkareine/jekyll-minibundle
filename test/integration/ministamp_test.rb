require 'support/test_case'
require 'nokogiri'

module Jekyll::Minibundle::Test
  class MiniStampTest < TestCase
    EXPECTED_ASSET_PATH = 'assets/site-390be921ee0eff063817bb5ef2954300.css'

    def test_asset_path_has_stamp
      actual = Nokogiri::HTML(read_from_gensite('index.html')).css('head link').first['href']
      assert_equal EXPECTED_ASSET_PATH, actual
    end

    def test_asset_file_is_copied_to_destination_dir
      assert File.exists?(gensite_path(EXPECTED_ASSET_PATH))
    end

    def test_asset_file_is_equal_to_source_file
      source_contents = File.read fixture_path('_tmp/site.css')
      destination_contents = File.read gensite_path(EXPECTED_ASSET_PATH)
      assert_equal source_contents, destination_contents
    end
  end
end
