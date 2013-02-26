require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFileTest < TestCase
    include FixtureConfig

    def test_consistent_fingerprint_in_file_and_markup
      with_site do
        with_env 'JEKYLL_MINIBUNDLE_CMD_JS' => cmd_to_remove_comments_and_count do
          bundle_file = BundleFile.new({
            'type'             => :js,
            'site_dir'         => '.',
            'source_dir'       => JS_BUNDLE_SOURCE_DIR,
            'assets'           => %w{dependency app},
            'destination_path' => JS_BUNDLE_DESTINATION_PATH,
            'attributes'       => {}
          })
          source = source_path JS_BUNDLE_SOURCE_DIR, 'app.js'
          old_destination = destination_path EXPECTED_JS_BUNDLE_PATH
          org_markup, last_markup = nil

          capture_io do
            org_markup = bundle_file.markup
            bundle_file.write '_site'
          end

          org_mtime = mtime_of old_destination

          assert_equal 1, get_cmd_count

          last_markup = bundle_file.markup
          ensure_file_mtime_changes { File.write source, '(function() {})()' }
          bundle_file.write '_site'

          # preserve fingerprint and content seen in last markup phase
          assert_equal org_markup, last_markup
          assert_equal org_mtime, mtime_of(old_destination)
          assert_equal 1, get_cmd_count

          capture_io do
            last_markup = bundle_file.markup
            bundle_file.write '_site'
          end

          new_destination = destination_path 'assets/site-375a0b430b0c5555d0edd2205d26c04d.js'

          # see updated fingerprint in the next round
          refute_equal org_markup, last_markup
          assert_operator mtime_of(new_destination), :>, org_mtime
          assert_equal 2, get_cmd_count
        end
      end
    end
  end
end
