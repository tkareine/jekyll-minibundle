module Jekyll::Minibundle
  module Hashes
    class << self
      def dig(obj, *keys)
        value = obj
        keys.each do |key|
          return nil unless value
          value = value[key]
        end
        value
      end
    end
  end
end
