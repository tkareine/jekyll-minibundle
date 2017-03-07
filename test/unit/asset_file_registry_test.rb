require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/asset_file_registry'

module Jekyll::Minibundle::Test
  class AssetFileRegistryTest < TestCase
    include FixtureConfig

    def setup
      AssetFileRegistry.clear_all
    end

    def test_register_returns_same_bundle_file_for_same_bundle_config
      with_fake_site do |site|
        first = AssetFileRegistry.register_bundle_file(site, bundle_config)
        second = AssetFileRegistry.register_bundle_file(site, bundle_config)
        assert_same(first, second)
        assert_equal(1, asset_file_registry_size)
        assert_contains_only(site.static_files, [first])
      end
    end

    def test_register_returns_same_development_file_collection_for_same_bundle_config
      with_fake_site do |site|
        first = AssetFileRegistry.register_development_file_collection(site, bundle_config)
        second = AssetFileRegistry.register_development_file_collection(site, bundle_config)
        assert_same(first, second)
        assert_equal(1, asset_file_registry_size)
        assert_contains_only(site.static_files, first.files)
      end
    end

    def test_register_returns_different_bundle_files_for_bundle_configs_with_different_destination_paths
      with_fake_site do |site|
        first = AssetFileRegistry.register_bundle_file(site, bundle_config.merge('destination_path' => 'assets/dest1'))
        second = AssetFileRegistry.register_bundle_file(site, bundle_config.merge('destination_path' => 'assets/dest2'))
        refute_same first, second
        assert_equal(2, asset_file_registry_size)
        assert_contains_only(site.static_files, [first, second])
      end
    end

    def test_register_returns_different_development_file_collections_for_bundle_configs_with_different_destination_paths
      with_fake_site do |site|
        first = AssetFileRegistry.register_development_file_collection(site, bundle_config.merge('destination_path' => 'assets/dest1'))
        second = AssetFileRegistry.register_development_file_collection(site, bundle_config.merge('destination_path' => 'assets/dest2'))
        refute_same first, second
        assert_equal(2, asset_file_registry_size)
        assert_contains_only(site.static_files, (first.files + second.files))
      end
    end

    def test_register_returns_different_bundle_files_for_bundle_configs_with_different_types
      with_fake_site do |site|
        FileUtils.touch(File.join(JS_BUNDLE_SOURCE_DIR, 'dependency.css'))
        FileUtils.touch(File.join(JS_BUNDLE_SOURCE_DIR, 'app.css'))
        first = AssetFileRegistry.register_bundle_file(site, bundle_config.merge('type' => :css))
        second = AssetFileRegistry.register_bundle_file(site, bundle_config.merge('type' => :js))
        refute_same first, second
        assert_equal(2, asset_file_registry_size)
        assert_contains_only(site.static_files, [first, second])
      end
    end

    def test_register_returns_different_development_file_collections_for_bundle_configs_with_different_types
      with_fake_site do |site|
        FileUtils.touch(File.join(JS_BUNDLE_SOURCE_DIR, 'dependency.css'))
        FileUtils.touch(File.join(JS_BUNDLE_SOURCE_DIR, 'app.css'))
        first = AssetFileRegistry.register_development_file_collection(site, bundle_config.merge('type' => :css))
        second = AssetFileRegistry.register_development_file_collection(site, bundle_config.merge('type' => :js))
        refute_same first, second
        assert_equal(2, asset_file_registry_size)
        assert_contains_only(site.static_files, (first.files + second.files))
      end
    end

    [
      {description: 'assets', config_diff: {'assets' => %w{b1 b2}}},
      {description: 'source_directory', config_diff: {'source_dir' => '_assets/src2'}}
    ].each do |spec|
      define_method :"test_raise_exception_if_registering_bundle_file_with_same_destination_path_but_with_different_#{spec.fetch(:description)}" do
        with_fake_site do |site|
          first_config = bundle_config
          first_file = AssetFileRegistry.register_bundle_file(site, first_config)
          second_config = bundle_config.merge(spec[:config_diff])
          err = assert_raises(RuntimeError) do
            AssetFileRegistry.register_bundle_file(site, second_config)
          end
          assert_equal(<<-END, err.to_s)
Two or more minibundle blocks with the same destination path "assets/site.js", but having different asset configuration: #{second_config.inspect} vs. #{first_config.inspect}
          END
          assert_equal(1, asset_file_registry_size)
          assert_contains_only(site.static_files, [first_file])
        end
      end
    end

    [
      {description: 'assets', config_diff: {'assets' => %w{b1 b2}}},
      {description: 'source_directory', config_diff: {'source_dir' => '_assets/src2'}}
    ].each do |spec|
      define_method :"test_raise_exception_if_registering_development_file_collection_with_same_destination_path_but_with_different_#{spec.fetch(:description)}" do
        with_fake_site do |site|
          first_config = bundle_config
          first_file = AssetFileRegistry.register_development_file_collection(site, first_config)
          second_config = bundle_config.merge(spec[:config_diff])
          err = assert_raises(RuntimeError) do
            AssetFileRegistry.register_development_file_collection(site, second_config)
          end
          assert_equal(<<-END, err.to_s)
Two or more minibundle blocks with the same destination path "assets/site.js", but having different asset configuration: #{second_config.inspect} vs. #{first_config.inspect}
          END
          assert_equal(1, asset_file_registry_size)
          assert_contains_only(site.static_files, first_file.files)
        end
      end
    end

    [
      {description: 'stamp_file', method: :register_stamp_file},
      {description: 'development_file', method: :register_development_file}
    ].each do |spec|
      define_method :"test_register_returns_same_#{spec.fetch(:description)}_for_same_source_and_destination_paths" do
        with_fake_site do |site|
          first = AssetFileRegistry.send(spec.fetch(:method), site, STAMP_SOURCE_PATH, 'assets/dest1.css')
          second = AssetFileRegistry.send(spec.fetch(:method), site, STAMP_SOURCE_PATH, 'assets/dest1.css')
          assert_same(first, second)
          assert_equal(1, asset_file_registry_size)
          assert_contains_only(site.static_files, [first])
        end
      end

      define_method :"test_register_returns_different_#{spec.fetch(:description)}s_for_different_source_and_destination_paths" do
        with_fake_site do |site|
          first = AssetFileRegistry.send(spec.fetch(:method), site, STAMP_SOURCE_PATH, 'assets/dest1.css')
          second = AssetFileRegistry.send(spec.fetch(:method), site, STAMP_SOURCE_PATH, 'assets/dest2.css')
          refute_same first, second
          assert_equal(2, asset_file_registry_size)
          assert_contains_only(site.static_files, [first, second])
        end
      end

      define_method :"test_raise_exception_if_registering_#{spec.fetch(:description)}s_with_different_source_and_same_destination_paths" do
        with_fake_site do |site|
          source_paths = %w{src1.css src2.css}.map do |file|
            File.join(CSS_BUNDLE_SOURCE_DIR, file)
          end
          source_paths.each { |path| FileUtils.touch(path) }
          first = AssetFileRegistry.send(spec.fetch(:method), site, source_paths[0], 'assets/dest1.css')
          err = assert_raises(RuntimeError) do
            AssetFileRegistry.send(spec.fetch(:method), site, source_paths[1], 'assets/dest1.css')
          end
          assert_equal(<<-END, err.to_s)
Two or more ministamp tags with the same destination path "assets/dest1.css", but different asset source paths: "#{source_paths[1]}" vs. "#{source_paths[0]}"
          END
          assert_equal(1, asset_file_registry_size)
          assert_contains_only(site.static_files, [first])
        end
      end
    end

    def test_raise_exception_if_registering_stamp_file_with_same_destination_path_as_existing_bundle_file
      with_fake_site do |site|
        FileUtils.touch('_assets/src.js')
        file = AssetFileRegistry.register_bundle_file(site, bundle_config.merge('destination_path' => 'assets/dest'))
        err = assert_raises(RuntimeError) do
          AssetFileRegistry.register_stamp_file(site, '_assets/src.js', 'assets/dest.js')
        end
        assert_equal('ministamp tag has the same destination path as a minibundle block: assets/dest.js', err.to_s)
        assert_equal(1, asset_file_registry_size)
        assert_contains_only(site.static_files, [file])
      end
    end

    def test_raise_exception_if_registering_bundle_file_with_same_destination_path_as_existing_stamp_file
      with_fake_site do |site|
        FileUtils.touch('_assets/src.js')
        file = AssetFileRegistry.register_stamp_file(site, '_assets/src.js', 'assets/dest.js')
        err = assert_raises(RuntimeError) do
          AssetFileRegistry.register_bundle_file(site, bundle_config.merge('destination_path' => 'assets/dest'))
        end
        assert_equal('minibundle block has the same destination path as a ministamp tag: assets/dest.js', err.to_s)
        assert_equal(1, asset_file_registry_size)
        assert_contains_only(site.static_files, [file])
      end
    end

    [
      {description: 'bundle_file', method: :register_bundle_file},
      {description: 'development_file_collection', method: :register_development_file_collection}
    ].each do |spec|
      define_method :"test_remove_unused_#{spec.fetch(:description)}" do
        with_fake_site do |site|
          AssetFileRegistry.send(spec.fetch(:method), site, bundle_config)
          AssetFileRegistry.clear_unused

          assert_equal(1, asset_file_registry_size)

          AssetFileRegistry.clear_unused

          assert_equal(0, asset_file_registry_size)
        end
      end
    end

    [
      {description: 'stamp_file', method: :register_stamp_file},
      {description: 'development_file', method: :register_development_file}
    ].each do |spec|
      define_method :"test_remove_unused_#{spec.fetch(:description)}" do
        with_fake_site do |site|
          AssetFileRegistry.send(spec.fetch(:method), site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH)
          AssetFileRegistry.clear_unused

          assert_equal(1, asset_file_registry_size)

          AssetFileRegistry.clear_unused

          assert_equal(0, asset_file_registry_size)
        end
      end
    end

    private

    def bundle_config
      {
        'type'             => :js,
        'source_dir'       => JS_BUNDLE_SOURCE_DIR,
        'assets'           => %w{dependency app},
        'destination_path' => JS_BUNDLE_DESTINATION_PATH,
        'minifier_cmd'     => 'unused_minifier_cmd'
      }
    end

    def asset_file_registry_size
      AssetFileRegistry.instance_variable_get(:@_files).size
    end
  end
end
