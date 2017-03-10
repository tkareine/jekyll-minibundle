require 'forwardable'

module Jekyll::Minibundle
  class AssetFileDrop < ::Liquid::Drop
    extend Forwardable

    KEYS = %w{
      name
      extname
      basename
      modified_time
      path
      collection
    }.freeze

    def initialize(file)
      @file = file
    end

    def key?(key)
      respond_to?(key)
    end

    def keys
      KEYS
    end

    def to_h
      keys.each_with_object({}) do |key, acc|
        acc[key] = self[key]
      end
    end

    alias to_hash to_h

    def inspect
      require 'json'
      JSON.pretty_generate(to_h)
    end

    def_delegators :@file, :name, :extname, :basename, :modified_time
    def_delegator :@file, :relative_path, :path
    def_delegator :@file, :type, :collection
  end
end
