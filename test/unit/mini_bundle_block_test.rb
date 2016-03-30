require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/mini_bundle_block'

module Jekyll::Minibundle::Test
  class MiniBundleBlockTest < TestCase
    include FixtureConfig

    def test_raise_exception_if_no_type_argument
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% minibundle %} {% endminibundle %}')
      end
      assert_equal "No asset type for minibundle block; pass value such as 'css' or 'js' as the argument", err.to_s
    end

    [
      {
        description:        'nil_baseurl_results_in_asset_url_without_baseurl',
        baseurl_config:     'baseurl:',
        expected_asset_url: CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH
      },
      {
        description:        'empty_baseurl_results_in_asset_url_without_baseurl',
        baseurl_config:     "baseurl: ''",
        expected_asset_url: CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH
      },
      {
        description:        'slash_baseurl_results_in_asset_url_with_baseurl',
        baseurl_config:     'baseurl: /',
        expected_asset_url: "/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}"
      },
      {
        description:        'slash_root_baseurl_results_in_asset_url_with_baseurl',
        baseurl_config:     'baseurl: /root',
        expected_asset_url: "/root/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}"
      },
      {
        description:        'slash_root_slash_baseurl_results_in_asset_url_with_baseurl',
        baseurl_config:     'baseurl: /root/',
        expected_asset_url: "/root/#{CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH}"
      }
    ].each do |spec|
      define_method :"test_normalizing_baseurl_with_#{spec.fetch(:description)}" do
        AssetFileRegistry.clear_all

        template = Liquid::Template.parse(<<-END)
{% minibundle css %}
source_dir: _assets/styles
destination_path: assets/site
#{spec.fetch(:baseurl_config)}
assets:
  - reset
  - common
minifier_cmd: #{minifier_cmd_to_remove_comments}
{% endminibundle %}
        END

        actual_output = nil
        capture_io do
          actual_output = template.render({}, registers: {site: new_fake_site(site_fixture_path)})
        end
        expected_output = %{<link rel="stylesheet" href="#{spec.fetch(:expected_asset_url)}">\n}

        assert_equal expected_output, actual_output
      end
    end
  end
end
