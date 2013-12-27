require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class StampFileTest < TestCase
    include FixtureConfig

    def test_calling_markup_determines_fingerprint_and_destination_write
      with_site do
        stamp_file = StampFile.new(STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH, &stamp_basenamer)

        source = source_path STAMP_SOURCE_PATH
        old_destination = destination_path STAMP_DESTINATION_FINGERPRINT_PATH

        org_markup = stamp_file.markup
        stamp_file.write '_site'
        org_mtime = mtime_of old_destination

        last_markup = stamp_file.markup
        ensure_file_mtime_changes { File.write source, 'h1 {}' }
        stamp_file.write '_site'

        # preserve fingerprint and content seen in last markup phase
        assert_equal org_markup, last_markup
        assert_equal org_mtime, mtime_of(old_destination)
        assert_equal File.read(site_fixture_path(STAMP_SOURCE_PATH)), File.read(old_destination)

        last_markup = stamp_file.markup
        stamp_file.write '_site'

        new_destination = destination_path 'assets/screen-0f5dbd1e527a2bee267e85007b08d2a5.css'

        # see updated fingerprint in the next round
        refute_equal org_markup, last_markup
        assert_operator mtime_of(new_destination), :>, org_mtime
        assert_equal File.read(source), File.read(new_destination)
      end
    end

    def test_many_consecutive_markup_calls_trigger_one_destination_write
      with_site do
        stamp_file = StampFile.new(STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH, &stamp_basenamer)

        source = source_path STAMP_SOURCE_PATH
        destination = destination_path STAMP_DESTINATION_FINGERPRINT_PATH

        org_markup = stamp_file.markup
        stamp_file.markup
        stamp_file.write '_site'
        org_mtime = mtime_of destination

        ensure_file_mtime_changes { FileUtils.touch source }

        last_markup = stamp_file.markup
        stamp_file.markup
        stamp_file.write '_site'

        assert_equal org_markup, last_markup
        assert_operator mtime_of(destination), :>, org_mtime
        assert_equal File.read(source), File.read(destination)
      end
    end

    private

    def stamp_basenamer
      ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
    end
  end
end
