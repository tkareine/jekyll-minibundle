require 'support/test_case'

module Jekyll::Minibundle::Test
  class StaticFileExistenceTest < TestCase
    [:development, :production].each do |env|
      define_method :"test_ministamp_source_file_known_to_jekyll_throws_exception_in_#{env}_env" do
        with_site do
          FileUtils.mkdir source_path('assets')
          FileUtils.touch source_path('assets/known.css')
          find_and_gsub_in_file(source_path('index.html'), '_tmp/site.css', 'assets/known.css')
          assert_static_file_exception('/assets/known.css') { generate_site env }
        end
      end

      define_method :"test_minibundle_source_file_known_to_jekyll_throws_exception_in_#{env}_env" do
        with_site do
          FileUtils.mkdir_p source_path('assets/scripts')
          FileUtils.touch source_path('assets/scripts/app.js')
          find_and_gsub_in_file(source_path('index.html'), 'source_dir: _assets/scripts', 'source_dir: assets/scripts')
          assert_static_file_exception('/assets/scripts/app.js') { generate_site env }
        end
      end
    end

    private

    def assert_static_file_exception(path, &block)
      err = assert_raises(RuntimeError, &block)
      escaped_path = Regexp.escape path
      assert_match(%r{^Minibundle cannot handle static file already handled by Jekyll: .+#{escaped_path}$}, err.message)
    end
  end
end
