require 'support/test_case'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle::Test
  class AssetTagMarkupTest < TestCase
    def test_escape_url
      actual = AssetTagMarkup.make_markup(:css, 'https://example.com/path?a=this+"thing"&b=<br>', {})
      expected = %{<link rel="stylesheet" href="https://example.com/path?a=this+&quot;thing&quot;&amp;b=&lt;br&gt;">}
      assert_equal(expected, actual)
    end

    def test_escape_attribute_value
      attributes = {media: 'screen, projection', extra: '">attack<br'}
      actual = AssetTagMarkup.make_markup(:css, '/asset.css', attributes)
      expected = %{<link rel="stylesheet" href="/asset.css" media="screen, projection" extra="&quot;&gt;attack&lt;br">}
      assert_equal(expected, actual)
    end

    def test_output_just_attribute_name_for_nil_value
      actual = AssetTagMarkup.make_markup(:css, '/asset.css', async: nil)
      expected = %{<link rel="stylesheet" href="/asset.css" async>}
      assert_equal(expected, actual)
    end

    def test_convert_attribute_value_to_string
      actual = AssetTagMarkup.make_markup(:css, '/asset.css', boolean: false)
      expected = %{<link rel="stylesheet" href="/asset.css" boolean="false">}
      assert_equal(expected, actual)
    end

    def test_output_empty_attribute_value
      actual = AssetTagMarkup.make_markup(:css, '/asset.css', empty: '')
      expected = %{<link rel="stylesheet" href="/asset.css" empty="">}
      assert_equal(expected, actual)
    end

    def test_raise_exception_if_unknown_type
      err = assert_raises(ArgumentError) do
        AssetTagMarkup.make_markup(:unknown, '/asset', {})
      end
      assert_equal('Unknown type for generating bundle markup: unknown, /asset', err.to_s)
    end
  end
end
