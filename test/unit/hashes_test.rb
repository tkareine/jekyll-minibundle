require 'support/test_case'
require 'jekyll/minibundle/hashes'

module Jekyll::Minibundle::Test
  class HashesTest < TestCase
    def test_dig_returns_value_when_found
      assert_equal(1, Hashes.dig({top: {middle: {leaf: 1}}}, :top, :middle, :leaf))
      assert_equal(1, Hashes.dig({top: [{}, {leaf: 1}]}, :top, 1, :leaf))
      assert_equal(1, Hashes.dig([{}, {middle: [{}, {leaf: 1}]}], 1, :middle, 1, :leaf))
    end

    def test_dig_returns_same_found_object
      leaf_obj = {leaf: 1}
      assert_same(leaf_obj, Hashes.dig({top: {middle: leaf_obj}}, :top, :middle))
    end

    def test_dig_returns_nil_when_not_found
      assert_nil(Hashes.dig({}, :no_such))
      assert_nil(Hashes.dig([], 0))
      assert_nil(Hashes.dig({top: {}}, :top, :no_such_leaf))
      assert_nil(Hashes.dig({top: {leaf: 1}}, :top, :no_such_leaf))
      assert_nil(Hashes.dig({top: []}, :top, 0))
      assert_nil(Hashes.dig([{leaf: 1}], 0, :no_such))
    end

    def test_dig_returns_nil_for_nil
      assert_nil(Hashes.dig(nil, :no_such_key))
      assert_nil(Hashes.dig(nil, 0))
    end

    def test_pick_returns_hash_with_specified_keys
      assert_equal({}, Hashes.pick(a: 1, 'b' => 2, 'c' => 3))
      assert_equal({}, Hashes.pick({}))
      assert_equal({a: 1, 'c' => 3}, Hashes.pick({a: 1, 'b' => 2, 'c' => 3}, :a, 'c'))
    end

    def test_pick_raises_exception_if_key_does_not_exist
      assert_raises(KeyError) { Hashes.pick({}, :no_such) }
    end
  end
end
