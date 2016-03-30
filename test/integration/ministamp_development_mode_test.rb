require 'support/test_case'
require 'support/fixture_config'

module Jekyll::Minibundle::Test
  class MinistampDevelopmentModeTest < TestCase
    include FixtureConfig

    def test_asset_destination_path_has_no_stamp
      with_precompiled_site(:development) do
        assert_equal STAMP_DESTINATION_PATH, find_css_path_from_index
        assert File.exist?(destination_path(STAMP_DESTINATION_PATH))
      end
    end

    def test_contents_of_asset_destination_are_equal_to_source
      with_precompiled_site(:development) do
        source_contents = File.read(site_fixture_path(STAMP_SOURCE_PATH))
        destination_contents = File.read(destination_path(STAMP_DESTINATION_PATH))
        assert_equal source_contents, destination_contents
      end
    end

    def test_changing_asset_source_file_rewrites_destination
      with_site_dir do
        generate_site(:development)

        org_mtime = mtime_of(destination_path(STAMP_DESTINATION_PATH))
        ensure_file_mtime_changes { File.write(source_path(STAMP_SOURCE_PATH), 'h1 {}') }

        generate_site(:development, clear_cache: false)

        new_mtime = mtime_of(destination_path(STAMP_DESTINATION_PATH))
        assert_operator new_mtime, :>, org_mtime
      end
    end

    def test_touching_asset_source_file_rewrites_destination
      with_site_dir do
        generate_site(:development)

        org_mtime = mtime_of(destination_path(STAMP_DESTINATION_PATH))
        ensure_file_mtime_changes { FileUtils.touch(source_path(STAMP_SOURCE_PATH)) }

        generate_site(:development, clear_cache: false)

        new_mtime = mtime_of(destination_path(STAMP_DESTINATION_PATH))
        assert_operator new_mtime, :>, org_mtime
      end
    end

    def test_changing_asset_source_path_rewrites_destination
      with_site_dir do
        generate_site(:development)

        org_mtime = mtime_of(destination_path(STAMP_DESTINATION_PATH))

        ensure_file_mtime_changes do
          FileUtils.mv(source_path('_tmp/site.css'), source_path('_tmp/site2.css'))

          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            '{% ministamp _tmp/site.css assets/screen.css',
            '{% ministamp _tmp/site2.css assets/screen.css'
          )
        end

        generate_site(:development, clear_cache: false)

        new_mtime = mtime_of(destination_path(STAMP_DESTINATION_PATH))

        assert_operator new_mtime, :>, org_mtime
      end
    end

    def test_changing_asset_destination_path_rewrites_destination
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(STAMP_DESTINATION_PATH))

        ensure_file_mtime_changes do
          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            '{% ministamp _tmp/site.css assets/screen.css',
            '{% ministamp _tmp/site.css assets/screen2.css'
          )
        end

        generate_site(:development, clear_cache: false)

        refute File.exist?(destination_path(STAMP_DESTINATION_PATH))

        new_destination = 'assets/screen2.css'

        assert_equal new_destination, find_css_path_from_index
        assert File.exist?(destination_path(new_destination))
      end
    end

    def test_changing_asset_destination_path_to_new_value_and_back_to_original_rewrites_destination
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(STAMP_DESTINATION_PATH))

        ensure_file_mtime_changes do
          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            '{% ministamp _tmp/site.css assets/screen.css',
            '{% ministamp _tmp/site.css assets/screen2.css'
          )
        end

        generate_site(:development, clear_cache: false)

        refute File.exist?(destination_path(STAMP_DESTINATION_PATH))

        new_destination = 'assets/screen2.css'

        assert_equal new_destination, find_css_path_from_index
        assert File.exist?(destination_path(new_destination))

        ensure_file_mtime_changes do
          find_and_gsub_in_file(
            source_path('_layouts/default.html'),
            '{% ministamp _tmp/site.css assets/screen2.css',
            '{% ministamp _tmp/site.css assets/screen.css'
          )
        end

        generate_site(:development, clear_cache: false)

        refute File.exist?(destination_path(new_destination))

        assert_equal STAMP_DESTINATION_PATH, find_css_path_from_index
        assert File.exist?(destination_path(STAMP_DESTINATION_PATH))
      end
    end

    def test_supports_relative_and_absolute_destination_paths
      with_site_dir do
        generate_site(:development)

        assert File.exist?(destination_path(STAMP_DESTINATION_PATH))
        assert_equal STAMP_DESTINATION_PATH, find_css_path_from_index

        find_and_gsub_in_file(
          source_path('_layouts/default.html'),
          '{% ministamp _tmp/site.css assets/screen.css',
          '{% ministamp _tmp/site.css /assets/screen.css'
        )

        generate_site(:development, clear_cache: false)

        assert_equal "/#{STAMP_DESTINATION_PATH}", find_css_path_from_index
      end
    end

    def test_does_not_rewrite_destination_when_nonsource_files_change
      with_site_dir do
        generate_site(:development)

        expected_path = destination_path(STAMP_DESTINATION_PATH)
        org_mtime = mtime_of(expected_path)
        ensure_file_mtime_changes { File.write(source_path(JS_BUNDLE_SOURCE_DIR, 'dependency.js'), '(function() {})()') }

        generate_site(:development, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_path)

        ensure_file_mtime_changes { FileUtils.touch('index.html') }

        generate_site(:development, clear_cache: false)

        assert_equal org_mtime, mtime_of(expected_path)
      end
    end

    private

    def find_css_path_from_index
      find_html_element(File.read(destination_path('index.html')), 'head link').first['href']
    end
  end
end
