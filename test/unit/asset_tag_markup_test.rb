require 'support/test_case'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle::Test
  class AssetTagMarkupTest < TestCase
    def test_escapes_attribute_values
      attributes = { media: 'screen, projection', extra: '">attack<br' }
      actual = AssetTagMarkup.make_markup(:css, '/asset', attributes)
      expected = %{<link rel="stylesheet" href="/asset" media="screen, projection" extra="&quot;&gt;attack&lt;br">}
      assert_equal expected, actual
    end

    def test_raise_exception_if_unknown_type
      err = assert_raises(ArgumentError) do
        AssetTagMarkup.make_markup(:unknown, '/asset', {})
      end
      assert_equal "Unknown type for generating bundle markup: unknown, /asset", err.to_s
    end
  end
end
