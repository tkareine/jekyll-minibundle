require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class StaticFilesAsAssetSourcesTest < TestCase
    include FixtureConfig

    def test_asset_and_static_files_with_same_destination_paths_can_coexist
      with_precompiled_site(:production) do
        actual = Dir[destination_path('assets/site*.*')].sort
        expected = [
          destination_path('assets/site.css'),
          destination_path(CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH),
          destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        ].sort
        assert_equal(expected, actual)
      end
    end

    [:development, :production].each do |env|
      define_method :"test_ministamp_allows_using_static_file_as_asset_source_in_#{env}_mode" do
        with_site_dir do
          contents = 'h2 {}'
          File.write(source_path('assets/shared.css'), contents)
          find_and_gsub_in_file(source_path('_layouts/default.html'), 'ministamp _tmp/site.css', 'ministamp assets/shared.css')

          generate_site(env)

          asset_files = Dir[destination_path('assets') + '/screen*.css']

          assert_equal(1, asset_files.size)
          assert_equal(contents, File.read(destination_path('assets/shared.css')))
          assert_equal(contents, File.read(asset_files.first))
        end
      end
    end

    def test_minibundle_allows_using_static_file_as_asset_source_in_development_mode
      with_site_dir do
        dep_contents = 'console.log("lol")'
        app_contents = 'console.log("balal")'
        File.write(source_path('assets/dependency.js'), dep_contents)
        File.write(source_path('assets/app.js'), app_contents)
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'source_dir: _assets/scripts', 'source_dir: assets')

        generate_site(:development)

        assert_equal(dep_contents, File.read(destination_path('assets/dependency.js')))
        assert_equal(app_contents, File.read(destination_path('assets/app.js')))
      end
    end

    def test_minibundle_allows_using_static_file_as_asset_source_in_production_mode
      with_site_dir do
        dep_contents = 'console.log("lol")'
        app_contents = 'console.log("balal")'
        bundled_contents = "#{dep_contents};\n#{app_contents};\n"
        File.write(source_path('assets/dependency.js'), dep_contents)
        File.write(source_path('assets/app.js'), app_contents)
        find_and_gsub_in_file(source_path('_layouts/default.html'), 'source_dir: _assets/scripts', 'source_dir: assets')

        generate_site(:production)

        asset_files = Dir[destination_path('assets/site-*.js')]

        assert_equal(1, asset_files.size)
        assert_equal(dep_contents, File.read(destination_path('assets/dependency.js')))
        assert_equal(app_contents, File.read(destination_path('assets/app.js')))
        assert_equal(bundled_contents, File.read(asset_files.first))
      end
    end
  end
end
