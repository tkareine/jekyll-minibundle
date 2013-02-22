require 'support/test_case'
require 'jekyll/minibundle/asset_bundle'

module Jekyll::Minibundle::Test
  class AssetBundleTest < TestCase
    def test_raise_exception_if_bundle_command_fails
      capture_io do
        with_env 'JEKYLL_MINIBUNDLE_CMD_JS' => 'false' do
          err = assert_raises(RuntimeError) { make_bundle }
          assert_equal 'Bundling js assets failed with exit status 1, command: false', err.to_s
        end
      end
    end

    def test_raise_exception_if_bundle_command_not_found
      with_env 'JEKYLL_MINIBUNDLE_CMD_JS' => 'no-such-jekyll-minibundle-cmd' do
        assert_raises(Errno::ENOENT) { make_bundle }
      end
    end

    def test_raise_exception_if_bundle_command_not_configured
      with_env 'JEKYLL_MINIBUNDLE_CMD_JS' => nil do
        err = assert_raises(RuntimeError) { make_bundle }
        assert_equal 'You need to set command for minification in $JEKYLL_MINIBUNDLE_CMD_JS', err.to_s
      end
    end

    private

    def make_bundle
      bundle = AssetBundle.new :js, [site_fixture_path('_assets/scripts/dependency.js')], site_fixture_path
      bundle.make_bundle
    end
  end
end
