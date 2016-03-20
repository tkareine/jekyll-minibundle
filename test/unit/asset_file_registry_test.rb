require 'support/test_case'
require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle::Test
  class AssetFileRegistryTest < TestCase
    def setup
      AssetFileRegistry.clear
      @site = new_site
    end

    def test_register_returns_same_bundle_file_for_same_bundle_configs
      first = AssetFileRegistry.register_bundle_file(@site, bundle_config)
      second = AssetFileRegistry.register_bundle_file(@site, bundle_config)
      assert_same first, second
      assert_equal 1, asset_file_registry_size
      assert_contains_only @site.static_files, [first]
    end

    def test_register_returns_same_development_file_collection_for_same_bundle_configs
      first = AssetFileRegistry.register_development_file_collection(@site, bundle_config)
      second = AssetFileRegistry.register_development_file_collection(@site, bundle_config)
      assert_same first, second
      assert_equal 1, asset_file_registry_size
      assert_contains_only @site.static_files, first.files
    end

    def test_register_returns_different_bundle_files_for_bundle_configs_with_different_destination_paths
      first = AssetFileRegistry.register_bundle_file(@site, bundle_config.merge('destination_path' => 'assets/dest1'))
      second = AssetFileRegistry.register_bundle_file(@site, bundle_config.merge('destination_path' => 'assets/dest2'))
      refute_same first, second
      assert_equal 2, asset_file_registry_size
      assert_contains_only @site.static_files, [first, second]
    end

    def test_register_returns_different_development_file_collections_for_bundle_configs_with_different_destination_paths
      first = AssetFileRegistry.register_development_file_collection(@site, bundle_config.merge('destination_path' => 'assets/dest1'))
      second = AssetFileRegistry.register_development_file_collection(@site, bundle_config.merge('destination_path' => 'assets/dest2'))
      refute_same first, second
      assert_equal 2, asset_file_registry_size
      assert_contains_only @site.static_files, (first.files + second.files)
    end

    def test_register_returns_different_bundle_files_for_bundle_configs_with_different_types
      first = AssetFileRegistry.register_bundle_file(@site, bundle_config.merge('type' => :css))
      second = AssetFileRegistry.register_bundle_file(@site, bundle_config.merge('type' => :js))
      refute_same first, second
      assert_equal 2, asset_file_registry_size
      assert_contains_only @site.static_files, [first, second]
    end

    def test_register_returns_different_development_file_collections_for_bundle_configs_with_different_types
      first = AssetFileRegistry.register_development_file_collection(@site, bundle_config.merge('type' => :css))
      second = AssetFileRegistry.register_development_file_collection(@site, bundle_config.merge('type' => :js))
      refute_same first, second
      assert_equal 2, asset_file_registry_size
      assert_contains_only @site.static_files, (first.files + second.files)
    end

    [
      {description: 'assets', config_diff: {'assets' => %w{b1 b2}}},
      {description: 'source_directory', config_diff: {'source_dir' => '_assets/src2'}}
    ].each do |spec|
      define_method :"test_register_replaces_cached_bundle_file_with_bundle_config_with_different_#{spec.fetch(:description)}" do
        first = AssetFileRegistry.register_bundle_file(@site, bundle_config)
        second = AssetFileRegistry.register_bundle_file(@site, bundle_config.merge(spec[:config_diff]))
        refute_same first, second
        assert_equal 1, asset_file_registry_size
        assert_contains_only @site.static_files, [second]
      end
    end

    [
      {description: 'assets', config_diff: {'assets' => %w{b1 b2}}},
      {description: 'source_directory', config_diff: {'source_dir' => '_assets/src2'}}
    ].each do |spec|
      define_method :"test_register_replaces_cached_development_file_collection_with_bundle_config_with_different_#{spec.fetch(:description)}" do
        first = AssetFileRegistry.register_development_file_collection(@site, bundle_config)
        second = AssetFileRegistry.register_development_file_collection(@site, bundle_config.merge(spec[:config_diff]))
        refute_same first, second
        assert_equal 1, asset_file_registry_size
        assert_contains_only @site.static_files, second.files
      end
    end

    [
      {description: 'stamp_file', method: :register_stamp_file},
      {description: 'development_file', method: :register_development_file}
    ].each do |spec|
      define_method :"test_register_returns_same_#{spec.fetch(:description)}_for_same_source_and_destination_paths" do
        first = AssetFileRegistry.send(spec.fetch(:method), @site, '_assets/src1.css', 'assets/dest1.css')
        second = AssetFileRegistry.send(spec.fetch(:method), @site, '_assets/src1.css', 'assets/dest1.css')
        assert_same first, second
        assert_equal 1, asset_file_registry_size
        assert_contains_only @site.static_files, [first]
      end

      define_method :"test_register_returns_different_#{spec.fetch(:description)}s_for_different_source_and_destination_paths" do
        first = AssetFileRegistry.send(spec.fetch(:method), @site, '_assets/src1.css', 'assets/dest1.css')
        second = AssetFileRegistry.send(spec.fetch(:method), @site, '_assets/src2.css', 'assets/dest2.css')
        refute_same first, second
        assert_equal 2, asset_file_registry_size
        assert_contains_only @site.static_files, [first, second]
      end

      define_method :"test_register_replaces_cached_#{spec.fetch(:description)}_with_different_source_and_same_destination_paths" do
        first = AssetFileRegistry.send(spec.fetch(:method), @site, '_assets/src1.css', 'assets/dest1.css')
        second = AssetFileRegistry.send(spec.fetch(:method), @site, '_assets/src2.css', 'assets/dest1.css')
        refute_same first, second
        assert_equal 1, asset_file_registry_size
        assert_contains_only @site.static_files, [second]
      end
    end

    def test_raise_exception_if_registering_stamp_file_with_same_destination_path_as_existing_bundle_file
      file = AssetFileRegistry.register_bundle_file(@site, bundle_config.merge('type' => :css, 'destination_path' => 'assets/dest'))
      err = assert_raises(RuntimeError) do
        AssetFileRegistry.register_stamp_file(@site, '_assets/src1.css', 'assets/dest.css')
      end
      assert_equal "ministamp tag has same destination path as a minibundle block: assets/dest.css", err.to_s
      assert_equal 1, asset_file_registry_size
      assert_contains_only @site.static_files, [file]
    end

    def test_raise_exception_if_registering_bundle_file_with_same_destination_path_as_existing_stamp_file
      file = AssetFileRegistry.register_stamp_file(@site, '_assets/src1.css', 'assets/dest.css')
      err = assert_raises(RuntimeError) do
        AssetFileRegistry.register_bundle_file(@site, bundle_config.merge('type' => :css, 'destination_path' => 'assets/dest'))
      end
      assert_equal "minibundle block has same destination path as a ministamp tag: assets/dest.css", err.to_s
      assert_equal 1, asset_file_registry_size
      assert_contains_only @site.static_files, [file]
    end

    private

    def bundle_config
      {
        'type'             => :css,
        'source_dir'       => '_assets/src',
        'assets'           => %w{dependency app},
        'destination_path' => 'assets/dest',
        'minifier_cmd'     => 'unused_minifier_cmd'
      }
    end

    def asset_file_registry_size
      AssetFileRegistry.instance_variable_get(:@_files).size
    end

    def new_site
      new_fake_site('.')
    end
  end
end
