require 'support/test_case'
require 'support/fixture_config'
require 'support/static_file_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFilePropertiesTest < TestCase
    include FixtureConfig
    include StaticFileConfig

    def setup
      @@results ||= with_bundle_file do |file|
        get_send_results(file, STATIC_FILE_PROPERTIES)
      end
    end

    def test_basename
      assert_equal("site-#{JS_BUNDLE_FINGERPRINT}", @@results.fetch(:basename))
    end

    def test_data
      assert_equal({}, @@results.fetch(:data))
    end

    def test_defaults
      assert_equal({}, @@results.fetch(:defaults))
    end

    def test_destination_rel_dir
      assert_equal('/assets', @@results.fetch(:destination_rel_dir))
    end

    def test_extname
      assert_equal('.js', @@results.fetch(:extname))
    end

    def test_modified_time
      assert_instance_of(Time, @@results.fetch(:modified_time))
    end

    def test_mtime
      mtime = @@results.fetch(:modified_time)
      assert_equal(mtime.to_i, @@results.fetch(:mtime))
    end

    def test_name
      assert_equal("site-#{JS_BUNDLE_FINGERPRINT}.js", @@results.fetch(:name))
    end

    def test_path
      assert_match(%r{\A/.+/jekyll-minibundle-.+\.js\z}, @@results.fetch(:path))
    end

    def test_placeholders
      assert_equal({}, @@results.fetch(:placeholders))
    end

    def test_relative_path
      assert_match(%r{/jekyll-minibundle-.+\.js\z}, @@results.fetch(:relative_path))
    end

    def test_to_liquid
      with_bundle_file do |file|
        drop = file.to_liquid
        assert_equal("site-#{JS_BUNDLE_FINGERPRINT}.js", drop.name)
        assert_equal('.js', drop.extname)
        assert_equal("site-#{JS_BUNDLE_FINGERPRINT}", drop.basename)
        assert_instance_of(Time, drop.modified_time)
        assert_match(%r{/jekyll-minibundle-.+\.js\z}, drop.path)
        assert_nil(drop.collection)
      end
    end

    def test_type
      assert_nil(@@results.fetch(:type))
    end

    def test_url
      assert_equal(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH, @@results.fetch(:url))
    end

    def test_write?
      assert(@@results.fetch(:write?))
    end

    private

    def with_bundle_file(&block)
      with_fake_site do |site|
        file = BundleFile.new(site, bundle_config(minifier_cmd_to_remove_comments))
        capture_io { file.destination_path_for_markup }
        block.call(file)
      end
    end

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
