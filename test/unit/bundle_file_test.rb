require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/bundle_file'

module Jekyll::Minibundle::Test
  class BundleFileTest < TestCase
    include FixtureConfig

    def test_calling_markup_determines_fingerprint_and_destination_write
      with_site do |site|
        with_env('JEKYLL_MINIBUNDLE_CMD_JS' => cmd_to_remove_comments_and_count) do
          bundle_file = BundleFile.new(site, bundle_config)
          source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
          old_destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
          org_markup, last_markup = nil
          capture_io { org_markup = bundle_file.markup }

          assert bundle_file.write('_site')

          org_mtime = mtime_of(old_destination)

          assert_equal 1, get_cmd_count

          last_markup = bundle_file.markup
          ensure_file_mtime_changes { File.write(source, '(function() {})()') }

          # preserve fingerprint and content seen in last markup phase
          refute bundle_file.write('_site')
          assert_equal org_markup, last_markup
          assert_equal org_mtime, mtime_of(old_destination)
          assert_equal 1, get_cmd_count

          capture_io { last_markup = bundle_file.markup }

          assert bundle_file.write('_site')

          new_destination = destination_path('assets/site-375a0b430b0c5555d0edd2205d26c04d.js')

          # see updated fingerprint in the next round
          refute_equal org_markup, last_markup
          assert_operator mtime_of(new_destination), :>, org_mtime
          assert_equal 2, get_cmd_count
        end
      end
    end

    def test_many_consecutive_markup_calls_trigger_one_destination_write
      with_site do |site|
        with_env('JEKYLL_MINIBUNDLE_CMD_JS' => cmd_to_remove_comments_and_count) do
          bundle_file = BundleFile.new(site, bundle_config)
          source = source_path(JS_BUNDLE_SOURCE_DIR, 'app.js')
          destination = destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH)
          org_markup, last_markup = nil
          capture_io { org_markup = bundle_file.markup }
          bundle_file.markup

          assert bundle_file.write('_site')

          org_mtime = mtime_of(destination)

          assert_equal 1, get_cmd_count

          ensure_file_mtime_changes { FileUtils.touch(source) }
          capture_io { last_markup = bundle_file.markup }
          bundle_file.markup

          assert bundle_file.write('_site')
          assert_equal org_markup, last_markup
          assert_operator mtime_of(destination), :>, org_mtime
          assert_equal 2, get_cmd_count
        end
      end
    end

    def test_calling_write_before_markup_has_no_effect
      with_site do |site|
        with_env('JEKYLL_MINIBUNDLE_CMD_JS' => cmd_to_remove_comments_and_count) do
          bundle_file = BundleFile.new(site, bundle_config)

          refute bundle_file.write('_site')
          assert_empty Dir[destination_path('assets/*.js')]
          assert_equal 0, get_cmd_count

          capture_io { bundle_file.markup }

          assert bundle_file.write('_site')
          assert File.exist?(destination_path(JS_BUNDLE_DESTINATION_FINGERPRINT_PATH))
          assert_equal 1, get_cmd_count
        end
      end
    end

    def test_to_liquid
      with_site do |site|
        hash = BundleFile.new(site, bundle_config).to_liquid
        assert_match(/jekyll-minibundle-js-/, hash['path'])
        refute_empty hash['modified_time']
      end
    end

    private

    def bundle_config
      {
       'type'             => :js,
       'source_dir'       => JS_BUNDLE_SOURCE_DIR,
       'assets'           => %w{dependency app},
       'destination_path' => JS_BUNDLE_DESTINATION_PATH,
       'attributes'       => {}
      }
    end
  end
end
