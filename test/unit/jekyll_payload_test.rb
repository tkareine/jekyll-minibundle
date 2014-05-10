require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/development_file_collection'
require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class JekyllPayloadTest < TestCase
    include FixtureConfig

    def test_sorts_stamp_files_in_site_payload
      with_site do |site|
        file = StampFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH, &stamp_basenamer)
        run_site_payload(site, file)
      end
    end

    def test_sorts_bundle_files_in_site_payload
      with_site do |site|
        file = BundleFile.new(site, bundle_config)
        run_site_payload(site, file)
      end
    end

    def test_sorts_development_files_in_site_payload
      with_site do |site|
        file = DevelopmentFileCollection.new(site, bundle_config)
        run_site_payload(site, file)
      end
    end

    private

    def with_site(&block)
      with_site_dir do
        yield new_real_site
      end
    end

    def run_site_payload(site, file)
      file.add_as_static_file_to(site)

      static_file = Jekyll::StaticFile.new(site, '.', 'dir', 'name.css')
      site.static_files << static_file

      site.site_payload
    end

    def stamp_basenamer
      ->(base, ext, stamper) { "#{base}-#{stamper.call}#{ext}" }
    end

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
