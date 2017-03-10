require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/mini_bundle_block'

module Jekyll::Minibundle::Test
  class MiniBundleBlockTest < TestCase
    include FixtureConfig

    def setup
      AssetFileRegistry.clear_all
    end

    def test_raise_exception_if_no_type_argument
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse('{% minibundle %} {% endminibundle %}')
      end
      assert_equal("Missing asset type for minibundle block; pass value such as 'css' or 'js' as the argument", err.to_s)
    end

    def test_raise_exception_if_missing_block_contents
      rendered = render_template(<<-END)
{% minibundle css %}

{% endminibundle %}
        END
      expected = "Liquid error: Missing configuration for minibundle block; pass configuration in YAML syntax\n"
      assert_equal(expected, rendered)
    end

    def test_raise_exception_if_invalid_block_contents_syntax
      rendered = render_template(<<-END)
{% minibundle css %}
}
{% endminibundle %}
        END
      expected =
        'Liquid error: Failed parsing minibundle block contents syntax as YAML: "}". ' \
        "Cause: (<unknown>): did not find expected node content while parsing a block node at line 2 column 1\n"
      assert_equal(expected, rendered)
    end

    def test_raise_exception_if_unsupported_block_contents_type
      rendered = render_template(<<-END)
{% minibundle css %}
str
{% endminibundle %}
        END
      assert_equal("Liquid error: Unsupported minibundle block contents type (String), only Hash is supported: \nstr\n\n", rendered)
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
        description:        'dot_baseurl_results_in_asset_url_without_baseurl',
        baseurl_config:     'baseurl: .',
        expected_asset_url: CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH
      },
      {
        description:        'dot_slash_baseurl_results_in_asset_url_without_baseurl',
        baseurl_config:     'baseurl: ./',
        expected_asset_url: CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH
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
        actual_output = render_template(<<-END)
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

        expected_output = %{<link rel="stylesheet" href="#{spec.fetch(:expected_asset_url)}">\n}

        assert_equal(expected_output, actual_output)
      end
    end

    private

    def render_template(template)
      compiled = Liquid::Template.parse(template)
      rendered = nil
      capture_io do
        rendered = compiled.render({}, registers: {site: make_fake_site(site_fixture_path)})
      end
      rendered
    end
  end
end
