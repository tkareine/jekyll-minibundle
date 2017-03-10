require 'support/test_case'
require 'jekyll/minibundle/development_file'
require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class JekyllStaticFileAPITest < TestCase
    def test_development_file_has_static_file_methods
      assert_empty(missing_static_file_methods(DevelopmentFile))
    end

    def test_bundle_file_has_static_file_methods
      assert_empty(missing_static_file_methods(BundleFile))
    end

    def test_stamp_file_has_static_file_methods
      assert_empty(missing_static_file_methods(StampFile))
    end

    def test_development_file_has_same_to_liquid_hash_keys_as_static_file
      with_empty_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('dev.js')

        expected_keys = make_static_file(site, 'static.txt').to_liquid.keys.sort
        actual_keys = make_development_file(site, 'dev.js').to_liquid.keys.sort

        assert_equal(expected_keys, actual_keys)
      end
    end

    def test_bundle_file_has_same_to_liquid_hash_keys_as_static_file
      with_empty_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('dependency.js')
        FileUtils.touch('app.js')

        expected_keys = make_static_file(site, 'static.txt').to_liquid.keys.sort
        actual_keys = make_bundle_file(site, %w{dependency app}).to_liquid.keys.sort

        assert_equal(expected_keys, actual_keys)
      end
    end

    def test_stamp_file_has_same_to_liquid_hash_keys_as_static_file
      with_empty_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('stamp.js')

        expected_keys = make_static_file(site, 'static.txt').to_liquid.keys.sort
        actual_keys = make_stamp_file(site, 'stamp.js').to_liquid.keys.sort

        assert_equal(expected_keys, actual_keys)
      end
    end

    private

    def missing_static_file_methods(clazz)
      Jekyll::StaticFile.public_instance_methods - clazz.public_instance_methods
    end

    def with_empty_site(&block)
      with_tmp_dir do |dir|
        block.call(make_fake_site(dir))
      end
    end

    def make_static_file(site, filename)
      ::Jekyll::StaticFile.new(
        site,
        nil,
        nil,
        filename
      )
    end

    def make_development_file(site, filename)
      DevelopmentFile.new(site, filename, filename)
    end

    def make_bundle_file(site, assets)
      BundleFile.new(
        site,
        'type'             => :js,
        'source_dir'       => '',
        'assets'           => assets,
        'destination_path' => 'bundle.js',
        'minifier_cmd'     => 'false'
      )
    end

    def make_stamp_file(site, filename)
      StampFile.new(site, filename, filename)
    end
  end
end
