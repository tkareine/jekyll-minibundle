require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFileWritingTest < TestCase
    include FixtureConfig

    def test_calling_markup_determines_fingerprint_and_destination_write
      with_fake_site do |site|
        bundle_file = BundleFile.new(site, bundle_config(minifier_cmd_to_remove_comments_and_count))
        source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
        old_destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_markup_path, last_markup_path = nil
        capture_io { org_markup_path = bundle_file.destination_path_for_markup }

        assert bundle_file.write('_site')

        org_mtime = mtime_of(old_destination)

        assert_equal 1, get_minifier_cmd_count

        last_markup_path = bundle_file.destination_path_for_markup
        ensure_file_mtime_changes { File.write(source, '(function() {})()') }

        # preserve fingerprint and content seen in last markup phase
        refute bundle_file.write('_site')
        assert_equal org_markup_path, last_markup_path
        assert_equal org_mtime, mtime_of(old_destination)
        assert_equal 1, get_minifier_cmd_count

        capture_io { last_markup_path = bundle_file.destination_path_for_markup }

        assert bundle_file.write('_site')

        new_destination = destination_path('assets/site-375a0b430b0c5555d0edd2205d26c04d.js')

        # see updated fingerprint in the next round
        refute_equal org_markup_path, last_markup_path
        assert_operator mtime_of(new_destination), :>, org_mtime
        assert_equal 2, get_minifier_cmd_count
      end
    end

    def test_many_consecutive_markup_calls_trigger_one_destination_write
      with_fake_site do |site|
        bundle_file = BundleFile.new(site, bundle_config(minifier_cmd_to_remove_comments_and_count))
        source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
        destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_markup_path, last_markup_path = nil
        capture_io { org_markup_path = bundle_file.destination_path_for_markup }
        bundle_file.destination_path_for_markup

        assert bundle_file.write('_site')

        org_mtime = mtime_of(destination)

        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes { FileUtils.touch(source) }
        capture_io { last_markup_path = bundle_file.destination_path_for_markup }
        bundle_file.destination_path_for_markup

        assert bundle_file.write('_site')
        assert_equal org_markup_path, last_markup_path
        assert_operator mtime_of(destination), :>, org_mtime
        assert_equal 2, get_minifier_cmd_count
      end
    end

    def test_calling_write_before_destination_path_for_markup_has_no_effect
      with_fake_site do |site|
        bundle_file = BundleFile.new(site, bundle_config(minifier_cmd_to_remove_comments_and_count))

        refute bundle_file.write('_site')
        assert_empty Dir[destination_path('assets/*.js')]
        assert_equal 0, get_minifier_cmd_count

        capture_io { bundle_file.destination_path_for_markup }

        assert bundle_file.write('_site')
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_equal 1, get_minifier_cmd_count
      end
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
