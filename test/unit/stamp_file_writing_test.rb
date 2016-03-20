require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class StampFileWritingTest < TestCase
    include FixtureConfig

    def test_calling_destination_path_for_markup_determines_fingerprint_and_destination_write
      with_fake_site do |site|
        stamp_file = new_stamp_file(site)
        source = source_path(STAMP_SOURCE_PATH)
        old_destination = destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)
        org_markup = stamp_file.destination_path_for_markup

        assert stamp_file.write('_site')

        org_mtime = mtime_of(old_destination)
        last_markup = stamp_file.destination_path_for_markup
        ensure_file_mtime_changes { File.write(source, 'h1 {}') }

        # preserve fingerprint and content seen in last markup phase
        refute stamp_file.write('_site')
        assert_equal org_markup, last_markup
        assert_equal org_mtime, mtime_of(old_destination)
        assert_equal File.read(site_fixture_path(STAMP_SOURCE_PATH)), File.read(old_destination)

        last_markup = stamp_file.destination_path_for_markup

        assert stamp_file.write('_site')

        new_destination = destination_path('assets/screen-0f5dbd1e527a2bee267e85007b08d2a5.css')

        # see updated fingerprint in the next round
        refute_equal org_markup, last_markup
        assert_operator mtime_of(new_destination), :>, org_mtime
        assert_equal File.read(source), File.read(new_destination)
      end
    end

    def test_many_consecutive_destination_path_for_markup_calls_trigger_one_destination_write
      with_fake_site do |site|
        stamp_file = new_stamp_file(site)
        source = source_path(STAMP_SOURCE_PATH)
        destination = destination_path(STAMP_DESTINATION_FINGERPRINT_PATH)
        org_markup = stamp_file.destination_path_for_markup
        stamp_file.destination_path_for_markup

        assert stamp_file.write('_site')

        org_mtime = mtime_of(destination)
        ensure_file_mtime_changes { FileUtils.touch(source) }
        last_markup = stamp_file.destination_path_for_markup
        stamp_file.destination_path_for_markup

        assert stamp_file.write('_site')
        assert_equal org_markup, last_markup
        assert_operator mtime_of(destination), :>, org_mtime
        assert_equal File.read(source), File.read(destination)
      end
    end

    def test_calling_write_before_destination_path_for_markup_has_no_effect
      with_fake_site do |site|
        stamp_file = new_stamp_file(site)

        refute stamp_file.write('_site')
        assert_empty Dir[destination_path('assets/*.css')]

        stamp_file.destination_path_for_markup

        assert stamp_file.write('_site')
        assert File.exist?(destination_path(STAMP_DESTINATION_FINGERPRINT_PATH))
      end
    end

    private

    def new_stamp_file(site)
      StampFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH)
    end
  end
end
