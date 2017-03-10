module Jekyll::Minibundle::Test
  module Assertions
    def assert_contains_only(collection, expected_elements)
      assert_respond_to collection, :size

      collection_size = collection.size
      expected_elements_size = expected_elements.size

      assert_equal(expected_elements_size, collection_size, lambda do
        "Expected #{mu_pp(collection)} to have size #{expected_elements_size} instead of #{collection_size}"
      end)

      remaining = collection.dup.to_a
      expected_elements.each do |e|
        index = remaining.index(e)
        remaining.delete_at(index) if index
      end

      assert(remaining.empty?, lambda do
        "Expected\n\n#{mu_pp(collection)}\n\nto include only\n\n#{mu_pp(expected_elements)}"
      end)
    end
  end
end
