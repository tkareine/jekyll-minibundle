require 'support/test_case'
require 'jekyll/minibundle/environment'

module Jekyll::Minibundle::Test
  class EnvironmentTest < TestCase
    def test_find_site_config_returns_value_when_found
      assert_equal(1, Environment.find_site_config(make_site(top: {leaf: 1}), [:top, :leaf], Integer))
    end

    def test_find_site_config_returns_nil_when_not_found
      assert_nil(Environment.find_site_config(make_site, [:top, :leaf], Integer))
    end

    def test_find_site_config_raises_exception_if_found_value_is_of_unexpected_type
      err = assert_raises(RuntimeError) do
        Environment.find_site_config(make_site(top: {leaf: '1'}), [:top, :leaf], Integer)
      end
      assert_equal('Invalid site configuration for key top.leaf; expecting type Integer', err.to_s)
    end

    private

    def make_site(config = {})
      OpenStruct.new(config: config)
    end
  end
end
