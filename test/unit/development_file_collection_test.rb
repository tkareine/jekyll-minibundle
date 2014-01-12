require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle::Test
  class DevelopmentFileCollectionTest < TestCase
    include FixtureConfig

    def test_calling_write_before_markup_writes_destination
      with_site do
        dev_files = DevelopmentFileCollection.new(bundle_config)

        assert first_file_of(dev_files).write('_site')

        destination_file = destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js')

        assert File.exists?(destination_file)

        org_mtime = mtime_of(destination_file)
        dev_files.markup

        refute first_file_of(dev_files).write('_site')
        assert_equal org_mtime, mtime_of(destination_file)
      end
    end

    private

    def bundle_config
      {
       'type'             => :js,
       'site_dir'         => '.',
       'source_dir'       => JS_BUNDLE_SOURCE_DIR,
       'assets'           => %w{dependency app},
       'destination_path' => JS_BUNDLE_DESTINATION_PATH,
       'attributes'       => {}
      }
    end

    def first_file_of(dev_files)
      dev_files.instance_variable_get(:@files).first
    end
  end
end
