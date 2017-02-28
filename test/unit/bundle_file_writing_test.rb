require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFileWritingTest < TestCase
    include FixtureConfig

    def test_calling_destination_path_for_markup_determines_fingerprint_and_destination_write
      with_fake_site do |site|
        bundle_file = make_bundle_file(site)
        source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
        old_destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_markup_path, last_markup_path = nil

        # the call to destination_path_for_markup determines the
        # fingerprint

        capture_io { org_markup_path = bundle_file.destination_path_for_markup }

        assert write_file(bundle_file)

        org_mtime = file_mtime_of(old_destination)

        assert_equal 1, get_minifier_cmd_count

        last_markup_path = bundle_file.destination_path_for_markup

        assert_equal org_markup_path, last_markup_path
        assert_equal 1, get_minifier_cmd_count

        # change content, but don't call destination_path_for_markup yet

        ensure_file_mtime_changes { File.write(source, '(function() {})()') }

        # preserve content's fingerprint

        refute write_file(bundle_file)

        assert_equal org_mtime, file_mtime_of(old_destination)
        assert_equal 1, get_minifier_cmd_count

        # see content's fingerprint to update after calling
        # destination_path_for_markup

        capture_io { last_markup_path = bundle_file.destination_path_for_markup }

        refute_equal org_markup_path, last_markup_path

        assert write_file(bundle_file)

        new_destination = destination_path('assets/site-375a0b430b0c5555d0edd2205d26c04d.js')

        assert_operator file_mtime_of(new_destination), :>, org_mtime
        assert_equal 2, get_minifier_cmd_count
      end
    end

    def test_many_consecutive_destination_path_for_markup_calls_trigger_one_destination_write
      with_fake_site do |site|
        bundle_file = make_bundle_file(site)
        source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
        destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
        org_markup_path, last_markup_path = nil
        capture_io { org_markup_path = bundle_file.destination_path_for_markup }
        bundle_file.destination_path_for_markup

        assert write_file(bundle_file)

        org_mtime = file_mtime_of(destination)

        assert_equal 1, get_minifier_cmd_count

        ensure_file_mtime_changes { FileUtils.touch(source) }
        capture_io { last_markup_path = bundle_file.destination_path_for_markup }
        bundle_file.destination_path_for_markup

        assert write_file(bundle_file)
        assert_equal org_markup_path, last_markup_path
        assert_operator file_mtime_of(destination), :>, org_mtime
        assert_equal 2, get_minifier_cmd_count
      end
    end

    def test_calling_write_before_destination_path_for_markup_has_no_effect
      with_fake_site do |site|
        bundle_file = make_bundle_file(site)

        refute write_file(bundle_file)
        assert_empty Dir[destination_path('assets/*.js')]
        assert_equal 0, get_minifier_cmd_count

        capture_io { bundle_file.destination_path_for_markup }

        assert write_file(bundle_file)
        assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
        assert_equal 1, get_minifier_cmd_count
      end
    end

    private

    def make_bundle_file(site)
      BundleFile.new(
        site,
        'type'             => :js,
        'source_dir'       => JS_BUNDLE_SOURCE_DIR,
        'assets'           => %w{dependency app},
        'destination_path' => JS_BUNDLE_DESTINATION_PATH,
        'minifier_cmd'     => minifier_cmd_to_remove_comments_and_count
      )
    end

    def write_file(file)
      file.write(File.join(Dir.pwd, '_site'))
    end
  end
end
