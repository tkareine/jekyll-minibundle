# frozen_string_literal: true

require_relative '../support/test_case'
require_relative '../support/static_file_config'
require 'jekyll/minibundle/development_file'
require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class JekyllStaticFileAPITest < TestCase
    IGNORED_STATIC_FILE_METHODS = %i[cleaned_relative_path].freeze

    include StaticFileConfig

    def test_development_file_has_most_static_file_methods
      assert_empty(missing_static_file_methods(DevelopmentFile))
    end

    def test_bundle_file_has_most_static_file_methods
      assert_empty(missing_static_file_methods(BundleFile))
    end

    def test_stamp_file_has_most_static_file_methods
      assert_empty(missing_static_file_methods(StampFile))
    end

    def test_development_file_properties_has_similar_return_types_to_static_file_properties
      with_real_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('dev.js')

        return_type_diff = diff_non_nil_response_types_of_static_file_properties(
          make_static_file(site, 'static.txt'),
          make_development_file(site, 'dev.js')
        )

        assert_empty(return_type_diff)
      end
    end

    def test_bundle_file_properties_has_similar_return_types_to_static_file_properties
      with_real_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('dependency.js')
        FileUtils.touch('app.js')

        return_type_diff = diff_non_nil_response_types_of_static_file_properties(
          make_static_file(site, 'static.txt'),
          make_bundle_file(site, 'assets' => %w[dependency app])
        )

        assert_empty(return_type_diff)
      end
    end

    def test_stamp_file_properties_has_similar_return_types_to_static_file_properties
      with_real_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('stamp.js')

        return_type_diff = diff_non_nil_response_types_of_static_file_properties(
          make_static_file(site, 'static.txt'),
          make_stamp_file(site, 'stamp.js')
        )

        assert_empty(return_type_diff)
      end
    end

    def test_development_file_has_same_to_liquid_hash_keys_as_static_file
      with_real_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('dev.js')

        expected_keys = make_static_file(site, 'static.txt').to_liquid.keys.sort
        actual_keys = make_development_file(site, 'dev.js').to_liquid.keys.sort

        assert_equal(expected_keys, actual_keys)
      end
    end

    def test_bundle_file_has_same_to_liquid_hash_keys_as_static_file
      with_real_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('dependency.js')
        FileUtils.touch('app.js')

        expected_keys = make_static_file(site, 'static.txt').to_liquid.keys.sort
        actual_keys = make_bundle_file(site, 'assets' => %w[dependency app]).to_liquid.keys.sort

        assert_equal(expected_keys, actual_keys)
      end
    end

    def test_stamp_file_has_same_to_liquid_hash_keys_as_static_file
      with_real_site do |site|
        FileUtils.touch('static.txt')
        FileUtils.touch('stamp.js')

        expected_keys = make_static_file(site, 'static.txt').to_liquid.keys.sort
        actual_keys = make_stamp_file(site, 'stamp.js').to_liquid.keys.sort

        assert_equal(expected_keys, actual_keys)
      end
    end

    def test_development_file_destination
      with_fake_site do |site|
        FileUtils.touch('dev.js')

        assert_equal(
          File.join(current_site_destination_dir, 'dev.js'),
          make_development_file(site, 'dev.js').destination(current_site_destination_dir)
        )

        assert_equal(
          File.join(current_site_destination_dir, 'dev.js'),
          make_development_file(site, '/dev.js').destination(current_site_destination_dir)
        )
      end

      with_fake_site do |site|
        FileUtils.mkdir('~')
        FileUtils.touch('~/dev.js')

        assert_equal(
          File.join(current_site_destination_dir, '~/dev.js'),
          make_development_file(site, '~/dev.js').destination(current_site_destination_dir)
        )
      end
    end

    def test_bundle_file_destination
      with_fake_site do |site|
        assert_match(
          %r{#{Regexp.escape(current_site_destination_dir)}/bundle-[a-z0-9]{32}\.js},
          make_bundle_file(site).destination(current_site_destination_dir)
        )

        assert_match(
          %r{#{Regexp.escape(current_site_destination_dir)}/bundle-[a-z0-9]{32}\.js},
          make_bundle_file(site, 'destination_path' => '/bundle').destination(current_site_destination_dir)
        )

        assert_match(
          %r{#{Regexp.escape(current_site_destination_dir)}/~/bundle-[a-z0-9]{32}\.js},
          make_bundle_file(site, 'destination_path' => '~/bundle').destination(current_site_destination_dir)
        )
      end
    end

    def test_stamp_file_destination
      with_fake_site do |site|
        FileUtils.touch('stamp.js')

        assert_match(
          %r{#{Regexp.escape(current_site_destination_dir)}/stamp-[a-z0-9]{32}\.js},
          make_stamp_file(site, 'stamp.js').destination(current_site_destination_dir)
        )

        assert_match(
          %r{#{Regexp.escape(current_site_destination_dir)}/stamp-[a-z0-9]{32}\.js},
          make_stamp_file(site, '/stamp.js').destination(current_site_destination_dir)
        )
      end

      with_fake_site do |site|
        FileUtils.mkdir('~')
        FileUtils.touch('~/stamp.js')

        assert_match(
          %r{#{Regexp.escape(current_site_destination_dir)}/~/stamp-[a-z0-9]{32}\.js},
          make_stamp_file(site, '~/stamp.js').destination(current_site_destination_dir)
        )
      end
    end

    private

    def missing_static_file_methods(clazz)
      Jekyll::StaticFile.public_instance_methods - IGNORED_STATIC_FILE_METHODS - clazz.public_instance_methods
    end

    def response_types_of_methods(file, methods)
      methods.each_with_object({}) do |method_name, acc|
        acc[method_name] =
          begin
            value = file.send(method_name)
            {returned_type: value.class}
          rescue StandardError => e
            {raised: e}
          end
      end
    end

    def diff_non_nil_response_types_of_static_file_properties(file_master, file_conforming)
      methods = STATIC_FILE_PROPERTIES - [:to_liquid]

      master_response_types = response_types_of_methods(file_master, methods)
      conforming_response_types = response_types_of_methods(file_conforming, methods)

      master_to_compare = master_response_types.select do |_, value|
        value.key?(:returned_type) && value.fetch(:returned_type) != NilClass
      end

      master_to_compare.to_a - conforming_response_types.to_a
    end

    def with_real_site(&block)
      with_site_dir do |dir|
        block.call(make_real_site(dir))
      end
    end

    def make_static_file(site, path)
      ::Jekyll::StaticFile.new(
        site,
        site.source,
        "/#{File.dirname(path)}",
        File.basename(path)
      )
    end

    def make_development_file(site, filename)
      DevelopmentFile.new(site, filename, filename)
    end

    def make_bundle_file(site, config = {})
      bundle_config = {
        'type'             => :js,
        'source_dir'       => '',
        'assets'           => [],
        'destination_path' => 'bundle',
        'minifier_cmd'     => 'false'
      }
      BundleFile.new(site, bundle_config.merge(config))
    end

    def make_stamp_file(site, filename)
      StampFile.new(site, filename, filename)
    end

    def current_site_destination_dir
      File.join(Dir.pwd, '_site')
    end
  end
end
