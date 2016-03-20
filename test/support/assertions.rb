module Jekyll::Minibundle::Test
  module Assertions
    def assert_contains_only(collection, expected_elements)
      assert_respond_to collection, :size

      collection_size = collection.size
      expected_elements_size = expected_elements.size

      assert_equal(expected_elements_size, collection_size, -> {
         "Expected #{mu_pp(collection)} to have size #{expected_elements_size} instead of #{collection_size}"
      })

      remaining = collection.dup.to_a
      expected_elements.each do |e|
        index = remaining.index(e)
        remaining.delete_at(index) if index
      end

      assert(remaining.empty?, -> {
        "Expected #{mu_pp(collection)} to include only #{mu_pp(expected_elements)}"
      })
    end
  end
end
