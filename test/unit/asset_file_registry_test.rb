require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle::Test
  class AssetFileRegistryTest < TestCase
    include FixtureConfig

    def setup
      AssetFileRegistry.clear
    end

    def test_returns_same_instance_for_same_stamp_file_config
      first = AssetFileRegistry.stamp_file STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH
      second = AssetFileRegistry.stamp_file STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH
      assert_same first, second
      assert_equal 1, asset_file_registry_size
    end

    def test_returns_same_instance_for_same_bundle_file_config
      first = AssetFileRegistry.bundle_file bundle_config
      second = AssetFileRegistry.bundle_file bundle_config
      assert_same first, second
      assert_equal 1, asset_file_registry_size
    end

    def test_bundle_files_allow_same_path_for_different_types
      AssetFileRegistry.bundle_file bundle_config.merge('type' => :css)
      AssetFileRegistry.bundle_file bundle_config.merge('type' => :js)
      assert_equal 2, asset_file_registry_size
    end

    private

    def bundle_config
      {
        'type'             => :css,
        'site_dir'         => '.',
        'source_dir'       => JS_BUNDLE_SOURCE_DIR,
        'assets'           => %w{dependency app},
        'destination_path' => JS_BUNDLE_DESTINATION_PATH,
        'attributes'       => {}
      }
    end

    def asset_file_registry_size
      AssetFileRegistry.class_variable_get(:@@_instances).size
    end
  end
end
