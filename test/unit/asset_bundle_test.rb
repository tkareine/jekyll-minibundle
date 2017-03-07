require 'support/test_case'
require 'jekyll/minibundle/asset_bundle'

module Jekyll::Minibundle::Test
  class AssetBundleTest < TestCase
    def test_raise_exception_if_bundle_command_fails
      capture_io do
        err = assert_raises(RuntimeError) { make_bundle('read _ignore ; false') }
        assert_equal('Bundling "assets/site.js" failed with exit status 1, command: "read _ignore ; false"', err.to_s)
      end
    end

    def test_log_minifier_stdout_if_bundle_command_fails
      cmd = 'ruby -E ISO-8859-15 -e \'gets; puts "line 1\a\nline\t2\xa4"; abort\''
      _, actual_stderr = capture_io do
        assert_raises(RuntimeError) { make_bundle(cmd) }
      end
      expected_stderr = <<-END
Minibundle: Bundling "assets/site.js" failed with exit status 1, command: #{cmd.inspect}, last 16 bytes of minifier output:
Minibundle: line 1\\x07
Minibundle: line 2\\xa4
      END
      assert_equal(expected_stderr, actual_stderr.gsub(/\e\[\d+m/, '').gsub(/^ +/, ''))
    end

    def test_raise_exception_if_bundle_command_not_found
      err = assert_raises(RuntimeError) { make_bundle('no-such-jekyll-minibundle-cmd') }
      assert_equal('Bundling "assets/site.js" failed: No such file or directory - no-such-jekyll-minibundle-cmd', err.to_s)
    end

    def test_raise_exception_if_bundle_command_not_configured
      err = assert_raises(RuntimeError) { make_bundle(nil) }
      expected_errmsg = <<-END
Missing minification command for bundling "assets/site.js". Specify it in
1) minibundle.minifier_commands.js setting in _config.yml,
2) $JEKYLL_MINIBUNDLE_CMD_JS environment variable, or
3) minifier_cmd setting inside minibundle block.
      END
      assert_equal(expected_errmsg, err.to_s)
    end

    private

    def make_bundle(minifier_cmd)
      bundle = AssetBundle.new(
        type:             :js,
        asset_paths:      [site_fixture_path('_assets/scripts/dependency.js')],
        destination_path: 'assets/site',
        site_dir:         site_fixture_path,
        minifier_cmd:     minifier_cmd
      )
      bundle.make_bundle
    end
  end
end
