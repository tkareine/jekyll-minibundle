# frozen_string_literal: true

module Jekyll::Minibundle
  module Hashes
    def self.dig(obj, *keys)
      value = obj
      keys.each do |key|
        return nil unless value

        value = value[key]
      end
      value
    end

    def self.pick(hash, *keys)
      keys.to_h { |key| [key, hash.fetch(key)] }
    end
  end
end
