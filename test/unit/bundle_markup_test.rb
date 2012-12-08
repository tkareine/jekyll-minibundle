require 'support/test_case'
require 'jekyll/minibundle/bundle_markup'

module Jekyll::Minibundle::Test
  class BundleMarkupTest < TestCase
    def test_escape_attribute_value
      attributes = { media: 'screen, projection', extra: '">attack<br' }
      actual = BundleMarkup.make_markup :css, 'http://localhost', attributes
      expected = %{<link rel="stylesheet" href="http://localhost" media="screen, projection" extra="&quot;&gt;attack&lt;br">}
      assert_equal expected, actual
    end
  end
end
