require 'support/test_case'
require 'support/fixture_config'
require 'support/static_file_api_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFilePropertiesTest < TestCase
    include FixtureConfig
    include StaticFileAPIConfig

    def setup
      @@results ||= with_fake_site do |site|
        file = BundleFile.new(site, bundle_config(minifier_cmd_to_remove_comments))
        capture_io { file.destination_path_for_markup }
        get_send_results(file, STATIC_FILE_API_PROPERTIES)
      end
    end

    def test_defaults
      assert_equal({}, @@results.fetch(:defaults))
    end

    def test_destination_rel_dir
      assert_equal 'assets', @@results.fetch(:destination_rel_dir)
    end

    def test_name
      assert_equal "site-#{JS_BUNDLE_FINGERPRINT}.js", @@results.fetch(:name)
    end

    def test_extname
      assert_equal '.js', @@results.fetch(:extname)
    end

    def test_modified_time
      assert_instance_of Time, @@results.fetch(:modified_time)
    end

    def test_mtime
      mtime = @@results.fetch(:modified_time)
      assert_equal mtime.to_i, @@results.fetch(:mtime)
    end

    def test_path
      assert_match(%r{/jekyll-minibundle-.+\.js\z}, @@results.fetch(:path))
    end

    def test_placeholders
      assert_equal({}, @@results.fetch(:placeholders))
    end

    def test_relative_path
      assert_match(%r{/jekyll-minibundle-.+\.js\z}, @@results.fetch(:relative_path))
    end

    def test_to_liquid
      hash = @@results.fetch(:to_liquid)
      assert_equal "site-#{JS_BUNDLE_FINGERPRINT}", hash.fetch('basename')
      assert_equal "site-#{JS_BUNDLE_FINGERPRINT}.js", hash.fetch('name')
      assert_equal '.js', hash.fetch('extname')
      assert_instance_of Time, hash.fetch('modified_time')
      assert_match(%r{/jekyll-minibundle-.+\.js\z}, hash.fetch('path'))
    end

    def test_type
      assert_nil @@results.fetch(:type)
    end

    def test_write?
      assert @@results.fetch(:write?)
    end

    private

    def bundle_config(minifier_cmd)
      {
        'type'             => :js,
        'source_dir'       => JS_BUNDLE_SOURCE_DIR,
        'assets'           => %w{dependency app},
        'destination_path' => JS_BUNDLE_DESTINATION_PATH,
        'minifier_cmd'     => minifier_cmd
      }
    end
  end
end
