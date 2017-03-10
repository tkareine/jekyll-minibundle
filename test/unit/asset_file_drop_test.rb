require 'json'
require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/asset_file_drop'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class AssetFileDropTest < TestCase
    include FixtureConfig

    def test_method_access_via_subscript_method
      with_drop do |drop|
        assert_equal("screen-#{STAMP_FINGERPRINT}.css", drop['name'])
      end
    end

    def test_method_access_via_forwarding
      with_drop do |drop|
        assert_equal("screen-#{STAMP_FINGERPRINT}.css", drop['name'])
      end
    end

    def test_key?
      with_drop do |drop|
        assert(drop.key?('name'))
      end
    end

    def test_to_h
      with_drop do |drop|
        hash = drop.to_h
        assert_equal(AssetFileDrop::KEYS.sort, hash.keys.sort)
        assert_equal("screen-#{STAMP_FINGERPRINT}.css", hash['name'])
        assert_equal('.css', hash['extname'])
        assert_equal("screen-#{STAMP_FINGERPRINT}", hash['basename'])
        assert_instance_of(Time, hash['modified_time'])
        assert_equal("/#{STAMP_SOURCE_PATH}", hash['path'])
        assert_nil(hash['collection'])
      end
    end

    def test_to_hash
      with_drop do |drop|
        assert_equal(drop.to_h, drop.to_hash)
      end
    end

    def test_inspect
      with_drop do |drop|
        assert_equal(drop.to_h.keys, JSON.parse(drop.inspect).keys)
      end
    end

    private

    def with_drop(&block)
      with_fake_site do |site|
        file = StampFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH)
        file.destination_path_for_markup
        drop = AssetFileDrop.new(file)
        block.call(drop)
      end
    end
  end
end
