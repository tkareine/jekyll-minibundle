require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class StampFileWritingTest < TestCase
    include FixtureConfig

    def test_raise_error_if_source_file_does_not_exist
      err = assert_raises(ArgumentError) do
        with_fake_site do |site|
          StampFile.new(site, '_tmp', STAMP_DESTINATION_PATH)
        end
      end
      assert_match(%r{\AStamp source file does not exist: .+/_tmp\z}, err.to_s)
    end

    def test_calling_destination_path_for_markup_determines_fingerprint_and_destination_write
      with_fake_site do |site|
        stamp_file = make_stamp_file(site)
        source = source_path(STAMP_SOURCE_PATH)
        old_destination = destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)

        # the call to destination_path_for_markup determines the
        # fingerprint

        org_markup_path = stamp_file.destination_path_for_markup

        assert(write_file(stamp_file))

        org_mtime = file_mtime_of(old_destination)

        last_markup_path = stamp_file.destination_path_for_markup

        assert_equal(org_markup_path, last_markup_path)

        # change content, but don't call destination_path_for_markup yet

        ensure_file_mtime_changes { File.write(source, 'h1 {}') }

        # preserve content's fingerprint

        refute(write_file(stamp_file))

        assert_equal(org_markup_path, last_markup_path)
        assert_equal(org_mtime, file_mtime_of(old_destination))
        assert_equal(File.read(site_fixture_path(STAMP_SOURCE_PATH)), File.read(old_destination))

        # see content's fingerprint to update after calling
        # destination_path_for_markup

        last_markup_path = stamp_file.destination_path_for_markup

        refute_equal org_markup_path, last_markup_path

        assert(write_file(stamp_file))

        new_destination = destination_path('assets/screen-0f5dbd1e527a2bee267e85007b08d2a5.css')

        assert_operator(file_mtime_of(new_destination), :>, org_mtime)
        assert_equal(File.read(source), File.read(new_destination))
      end
    end

    def test_many_consecutive_destination_path_for_markup_calls_trigger_one_destination_write
      with_fake_site do |site|
        stamp_file = make_stamp_file(site)
        source = source_path(STAMP_SOURCE_PATH)
        destination = destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)
        org_markup = stamp_file.destination_path_for_markup
        stamp_file.destination_path_for_markup

        assert(write_file(stamp_file))

        org_mtime = file_mtime_of(destination)
        ensure_file_mtime_changes { FileUtils.touch(source) }
        last_markup = stamp_file.destination_path_for_markup
        stamp_file.destination_path_for_markup

        assert(write_file(stamp_file))
        assert_equal(org_markup, last_markup)
        assert_operator(file_mtime_of(destination), :>, org_mtime)
        assert_equal(File.read(source), File.read(destination))
      end
    end

    def test_calling_write_before_destination_path_for_markup_has_no_effect
      with_fake_site do |site|
        stamp_file = make_stamp_file(site)

        refute(write_file(stamp_file))
        assert_empty(Dir[destination_path('assets/*.css')])

        stamp_file.destination_path_for_markup

        assert(write_file(stamp_file))
        assert(File.file?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)))
      end
    end

    def test_modified_property_determines_if_write_would_succeed
      with_fake_site do |site|
        stamp_file = make_stamp_file(site)

        refute(stamp_file.modified?)
        refute(write_file(stamp_file))

        stamp_file.destination_path_for_markup

        assert(stamp_file.modified?)
        assert(write_file(stamp_file))

        refute(stamp_file.modified?)
        refute(write_file(stamp_file))
      end
    end

    private

    def make_stamp_file(site)
      StampFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH)
    end

    def write_file(file)
      file.write(File.join(Dir.pwd, '_site'))
    end
  end
end
