require 'support/test_case'
require 'jekyll/minibundle/mini_bundle_block'

module Jekyll::Minibundle::Test
  class MiniBundleBlockTest < TestCase
    def test_raise_exception_if_no_type_argument
      err = assert_raises(ArgumentError) do
        Liquid::Template.parse("{% minibundle %} {% endminibundle %}")
      end
      assert_equal "No asset type for minibundle block; pass value such as 'css' or 'js' as the argument", err.to_s
    end
  end
end
