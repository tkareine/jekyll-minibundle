require 'support/test_case'
require 'jekyll/minibundle/asset_bundle'

module Jekyll::Minibundle::Test
  class AssetBundleTest < TestCase
    def test_raise_exception_if_bundle_command_fails
      capture_io do
        err = assert_raises(RuntimeError) { make_bundle('false') }
        assert_equal 'Bundling js assets failed with exit status 1, command: false', err.to_s
      end
    end

    def test_raise_exception_if_bundle_command_not_found
      assert_raises(Errno::ENOENT) { make_bundle('no-such-jekyll-minibundle-cmd') }
    end

    def test_raise_exception_if_bundle_command_not_configured
      err = assert_raises(RuntimeError) { make_bundle(nil) }
      assert_equal 'You need to set command for minification in $JEKYLL_MINIBUNDLE_CMD_JS', err.to_s
    end

    private

    def make_bundle(minifier_cmd)
      bundle = AssetBundle.new(
        type: :js,
        asset_paths: [site_fixture_path('_assets/scripts/dependency.js')],
        site_dir: site_fixture_path,
        minifier_cmd: minifier_cmd
      )
      bundle.make_bundle
    end
  end
end
