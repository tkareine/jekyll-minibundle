require 'support/test_case'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle::Test
  class AssetTagMarkupTest < TestCase
    def test_escapes_attribute_values
      attributes = { media: 'screen, projection', extra: '">attack<br' }
      actual = AssetTagMarkup.make_markup(:css, '', '/asset.css', attributes)
      expected = %{<link rel="stylesheet" href="/asset.css" media="screen, projection" extra="&quot;&gt;attack&lt;br">}
      assert_equal expected, actual
    end

    def test_raise_exception_if_unknown_type
      err = assert_raises(ArgumentError) do
        AssetTagMarkup.make_markup(:unknown, '', '/asset', {})
      end
      assert_equal "Unknown type for generating bundle markup: unknown, /asset", err.to_s
    end

    def test_joins_empty_baseurl_and_path
      assert_equal %{<link rel="stylesheet" href="asset.css">}, AssetTagMarkup.make_markup(:css, '', 'asset.css', {})
    end

    def test_joins_nonempty_baseurl_and_path
      assert_equal %{<link rel="stylesheet" href="/root/path/asset.css">}, AssetTagMarkup.make_markup(:css, '/root', 'path/asset.css', {})
    end

    def test_removes_extra_slash_between_baseurl_and_path
      assert_equal %{<link rel="stylesheet" href="/asset.css">}, AssetTagMarkup.make_markup(:css, '/', '/asset.css', {})
    end
  end
end
