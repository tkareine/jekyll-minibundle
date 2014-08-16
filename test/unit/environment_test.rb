require 'support/test_case'
require 'jekyll/minibundle/environment'

module Jekyll::Minibundle::Test
  class EnvironmentTest < TestCase
    def test_traverse_keys_returns_value_when_found
      assert_equal 1, Environment.traverse_keys({top: {middle: {leaf: 1}}}, [:top, :middle, :leaf])
      assert_equal({leaf: 1}, Environment.traverse_keys({top: {middle: {leaf: 1}}}, [:top, :middle]))
      assert_equal 1, Environment.traverse_keys({top: [{}, {leaf: 1}]}, [:top, 1, :leaf])
    end

    def test_traverse_keys_returns_nil_when_not_found
      assert_nil Environment.traverse_keys({}, [:top, :no_such_leaf])
      assert_nil Environment.traverse_keys({top: {}}, [:top, :no_such_leaf])
      assert_nil Environment.traverse_keys({top: {leaf: 1}}, [:top, :no_such_leaf])
      assert_nil Environment.traverse_keys({top: []}, [:top, 0])
    end

    def test_find_site_config_returns_value_when_found
      assert_equal 1, Environment.find_site_config(new_site(top: {leaf: 1}), [:top, :leaf], Integer)
    end

    def test_find_site_config_returns_nil_when_not_found
      assert_nil Environment.find_site_config(new_site, [:top, :leaf], Integer)
    end

    def test_find_site_config_raises_exception_if_found_value_is_of_unexpected_type
      err = assert_raises(RuntimeError) do
        Environment.find_site_config(new_site(top: {leaf: '1'}), [:top, :leaf], Integer)
      end
      assert_equal 'Invalid site configuration for key top.leaf; expecting type Integer', err.to_s
    end

    private

    def new_site(config = {})
      OpenStruct.new(config: config)
    end
  end
end
