require 'support/test_case'
require 'jekyll/minibundle/asset_tag_markup'

module Jekyll::Minibundle::Test
  class AssetTagMarkupTest < TestCase
    def test_escape_attribute_value
      attributes = { media: 'screen, projection', extra: '">attack<br' }
      actual = AssetTagMarkup.make_markup :css, 'http://localhost', attributes
      expected = %{<link rel="stylesheet" href="http://localhost" media="screen, projection" extra="&quot;&gt;attack&lt;br">}
      assert_equal expected, actual
    end
  end
end
