require 'support/test_case'
require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle::Test
  class AssetFileRegistryTest < TestCase
    def setup
      AssetFileRegistry.clear
    end

    def test_returns_same_stamp_file_instance_for_same_destination_path
      first = AssetFileRegistry.stamp_file('_assets/src1.css', 'assets/dest.css')
      second = AssetFileRegistry.stamp_file('_assets/src2.css', 'assets/dest.css')
      assert_same first, second
      assert_equal 1, asset_file_registry_size
    end

    def test_returns_same_bundle_file_instance_for_same_destination_path_and_type
      first = AssetFileRegistry.bundle_file(bundle_config.merge('assets' => %w{a1 a2}))
      second = AssetFileRegistry.bundle_file(bundle_config.merge('assets' => %w{b1 b2}))
      assert_same first, second
      assert_equal 1, asset_file_registry_size
    end

    def test_bundle_files_allow_same_path_for_different_types
      AssetFileRegistry.bundle_file(bundle_config.merge('type' => :css))
      AssetFileRegistry.bundle_file(bundle_config.merge('type' => :js))
      assert_equal 2, asset_file_registry_size
    end

    private

    def bundle_config
      {
        'type'             => :css,
        'site_dir'         => '.',
        'source_dir'       => '_assets/styles',
        'assets'           => %w{dependency app},
        'destination_path' => 'assets/site',
        'attributes'       => {}
      }
    end

    def asset_file_registry_size
      AssetFileRegistry.class_variable_get(:@@_instances).size
    end
  end
end
