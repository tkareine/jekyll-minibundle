require 'support/test_case'
require 'jekyll/minibundle/environment'

module Jekyll::Minibundle::Test
  class EnvironmentTest < TestCase
    def test_hash_traverse_returns_value_when_found
      assert_equal 1, Environment.traverse_hash({top: {middle: {leaf: 1}}}, [:top, :middle, :leaf])
      assert_equal({leaf: 1}, Environment.traverse_hash({top: {middle: {leaf: 1}}}, [:top, :middle]))
    end

    def test_hash_traverse_returns_nil_when_not_found
      assert_nil Environment.traverse_hash({}, [:top, :no_such_leaf])
      assert_nil Environment.traverse_hash({top: {}}, [:top, :no_such_leaf])
      assert_nil Environment.traverse_hash({top: {leaf: 1}}, [:top, :no_such_leaf])
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
