require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle::Test
  class DevelopmentFileCollectionTest < TestCase
    include FixtureConfig

    def test_calling_write_before_destination_path_for_markup_writes_destination
      with_site do |site|
        dev_files = DevelopmentFileCollection.new(site, bundle_config)

        assert first_file_of(dev_files).write('_site')

        destination_file = destination_path(JS_BUNDLE_DESTINATION_PATH, 'dependency.js')

        assert File.exist?(destination_file)

        org_mtime = mtime_of(destination_file)
        dev_files.destination_path_for_markup

        refute first_file_of(dev_files).write('_site')
        assert_equal org_mtime, mtime_of(destination_file)
      end
    end

    def test_to_liquid
      with_site do |site|
        files = DevelopmentFileCollection.new(site, bundle_config).
            instance_variable_get('@files').
            sort_by { |f| f.path }

        hash = files[0].to_liquid

        assert_equal "/#{JS_BUNDLE_SOURCE_DIR}/app.js", hash['path']
        refute_empty hash['modified_time']
        assert_equal '.js', hash['extname']

        hash = files[1].to_liquid

        assert_equal "/#{JS_BUNDLE_SOURCE_DIR}/dependency.js", hash['path']
        refute_empty hash['modified_time']
        assert_equal '.js', hash['extname']
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

    def first_file_of(dev_files)
      dev_files.instance_variable_get(:@files).first
    end
  end
end
