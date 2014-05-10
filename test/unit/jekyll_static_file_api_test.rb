require 'support/test_case'
require 'jekyll/minibundle/development_file'
require 'jekyll/minibundle/bundle_file'
require 'jekyll/minibundle/stamp_file'

module Jekyll::Minibundle::Test
  class JekyllStaticFileAPITest < TestCase
    def test_development_file_conforms_to_static_file_api
      assert_empty missing_api_methods(DevelopmentFile)
    end

    def test_bundle_file_conforms_to_static_file_api
      assert_empty missing_api_methods(BundleFile)
    end

    def test_stamp_file_conforms_to_static_file_api
      assert_empty missing_api_methods(StampFile)
    end

    private

    def missing_api_methods(clazz)
      Jekyll::StaticFile.public_instance_methods - clazz.public_instance_methods
    end
  end
end
