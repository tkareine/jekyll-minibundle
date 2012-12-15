require 'support/test_case'
require 'jekyll/minibundle/asset_bundle'

module Jekyll::Minibundle::Test
  class AssetBundleTest < TestCase
    def test_raise_exception_if_bundle_command_fails
      capture_io do
        with_env('JEKYLL_MINIBUNDLE_CMD_JS' => 'false') do
          bundle = AssetBundle.new :js, [fixture_path('_assets/scripts/dependency.js')], fixture_path
          err = assert_raises(RuntimeError) { bundle.make_bundle }
          assert_equal 'Bundling js assets failed with exit status 1, command: false', err.to_s
        end
      end
    end
  end
end
